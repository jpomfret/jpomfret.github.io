---
title: "Dab Api Container"
slug: "dab-api-container"
description: "ENTER YOUR DESCRIPTION"
date: 2025-08-21T09:45:18Z
categories:
tags:
image:
draft: true
---

This is post 2 in my series about the Data API Builder (dab), the first post, [Data API Builder](/dab-api-builder/), covers what dab is and how to test it locally against SQL Server in running in a container.

This is great for testing, but now we want to start to productionise this, and the first step is to get it running somewhere other than my laptop.

There are several deployment options available, I recommend you review the Microsoft docs here: [Deployment guidance for Data API builder](https://learn.microsoft.com/en-us/azure/data-api-builder/deployment/).

In this post I'm going to show you how to get it running in an [Azure Container Instance](https://learn.microsoft.com/en-us/azure/container-instances/), this is a cheap and cheerful way of getting this into the cloud. If you need more features like auto-scaling and better monitoring take a look at [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/) instead, the deployment is very similar to the process in this blog.

## Azure SQL Database

We're going to build on what we created in the first post, and instead of running against a local SQL Server instance we'll use an Azure SQL Database. You can deploy a [free Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/free-offer?view=azuresql) with the Azure CLI as shown below.

You'll notice I have specified on the database resource to use my free limit and if I run out, pause, rather than start charging with the `--use-free-limit --free-limit-exhaustion-behavior AutoPause` parameters.

#TODO: explain the external-admin-sid bit?
```PowerShell
$location = 'UKSouth'
$resourceGroup = 'rg-dab-prod-001'
$server = 'sqlsvr-dab-prod-001'
$database = 'sqldb-dab-prod-001'
$adminUser ="databaseadmin"
$adminPassword ="dbatools.IO!"

$adminID = az ad group show --group "SQLAdmin" --query "id" -o tsv
az group create --name $resourceGroup --location $location
az sql server create `
  --name $server `
  --resource-group $resourceGroup `
  --location $location `
  --admin-user $adminUser `
  --admin-password $adminPassword `
  --external-admin-sid $adminID `
  --external-admin-name SQLAdmin `
  --external-admin-principal-type group

az sql db create `
  --resource-group $resourceGroup `
  --server $server `
  --name $database `
  --sample-name AdventureWorksLT `
  --edition GeneralPurpose `
  --family Gen5 `
  --capacity 2 `
  --compute-model Serverless `
  --use-free-limit `
  --free-limit-exhaustion-behavior AutoPause
```

Once that completes, you'll be able to see your database in the [Azure Portal](http://portal.azure.com/), and note your connection string as we'll need that shortly.

{{<
    figure src="freeSqlDb.png"
    alt="Free Azure SQL Database"
  link="freeSqlDb.png"
>}}

## DAB Config

Now we have a database in the cloud to connect to we can set up our `dab-config.json`. In the previous post when we were testing locally we connected to a local docker container, with a hardcoded password. This time we will replace our connection string with an environment variable and then we'll configure the container instance to pass that in.

To create the `dab-config.json` you can run the following code, this will create the config with all the defaults for a SQL Server, but it'll set the connection string ready for our environment variable.

```PowerShell
dab init --database-type "mssql" --connection-string "@env('DATABASE_CONNECTION_STRING')"
```

Next we'll add the entities we want to expose from the database, if you want to add all the database tables, you can use [dbatools](http://dbatools.io/) to grab a list of tables and then loop through them running `dab add` for each entity.

TODO: change to azure auth?

```PowerShell
$cred = get-Credential databaseadmin
$conn = Connect-DbaInstance -SqlInstance sqlsvr-dab-prod-001.database.windows.net -SqlCredential $cred
$tables = get-dbadbtable -sqlinstance $conn -Database sqldb-dab-prod-001
$tables.ForEach{
    dab add ('{0}_{1}' -f $psitem.schema, $psitem.Name) --source ('{0}.{1}' -f $psitem.Schema, $psitem.Name) --permissions "anonymous:*"
}
```

> **💡 Note: Firewall Access**
>
> If you get a connection error about your IP address not being allowed, you'll need to add a firewall rule for your current IP, you can do that using the az cli:
>
> ```PowerShell
> $ipAddress = (iwr https://icanhazip.com/).content.Trim()
> az sql server firewall-rule create `
>   --resource-group rg-dab-prod-001 `
>   --server sqlsvr-dab-prod-001 `
>   --name "MyDevMachine" `
>   --start-ip-address $ipAddress `
>   --end-ip-address $ipAddress
> ```
>
> The firewall change typically takes effect within a few minutes.

If you view your `dab-config.json` file, you should see lots of entities that have been added.

## Config Storage

Alright, now the `dab-config.json` is ready we need to store it somewhere, and the easiest option here is a file share in Azure. Let's create a storage account and a file share in the same resource group we created earlier. Remember that your storage account name has to be lowercase and globally unique.

```PowerShell
$storageAccount = "dabconfigstorage1234"  # Must be globally unique
$fileShareName = "dab-config"

# Create storage account
az storage account create `
  --name $storageAccount `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-shared-key-access true

# Create file share
az storage share create `
  --name $fileShareName `
  --account-name $storageAccount
```

Now the share is in place we can upload the `dab-config.json` that we created earlier. You can use the Azure CLI to upload this file, first grab the account key, and then use `az storage file upload` to place the config file in Azure.

```PowerShell
$storageKey = az storage account keys list `
  --resource-group $resourceGroup `
  --account-name $storageAccount `
  --query "[0].value" `
  --output tsv

az storage file upload --account-key $storageKey `
  --account-name $storageAccount `
  --share-name $fileShareName `
  --source dab-config.json
```

## Azure Container Instance

Alright, that's the config in place, now we will focus on creating our Azure Container Instance and wiring it up to use the config. When we created the `dab-config.json` file we set the connection string to an environment variable called `DATABASE_CONNECTION_STRING` so we need to populate this with the connection string to the Azure SQL Server we created earlier.

```PowerShell
$containerName = 'ci-dab-prod-001'
$dnsLabel = 'ci-dab-prod-001'  # Must be globally unique
$image = 'mcr.microsoft.com/azure-databases/data-api-builder:latest'

$connectionString = ('Server=tcp:{0}.database.windows.net,1433;Initial Catalog={1};Authentication=Active Directory Default;Encrypt=True;Connection Timeout=30;' -f $server, $database)


# tested with this for sql auth:
$connectionString = "Server=tcp:$server.database.windows.net,1433;Initial Catalog=$database;User ID=$adminUser;Password=$adminPassword;Encrypt=True;Connection Timeout=30;"


az container create `
  --resource-group $resourceGroup `
  --name $containerName `
  --image $image `
  --dns-name-label $dnsLabel `
  --location $location `
  --sku "Standard" `
  --os-type "Linux" `
  --ip-address "public" `
  --cpu 1 `
  --memory 1.5 `
  --ports "5000" `
  --environment-variables "DATABASE_CONNECTION_STRING=$connectionString" `
  --azure-file-volume-mount-path "/cfg" `
  --azure-file-volume-account-name $storageAccount `
  --azure-file-volume-account-key $storageKey `
  --azure-file-volume-share-name $fileShareName `
  --command-line "dotnet Azure.DataApiBuilder.Service.dll --ConfigFileName /cfg/dab-config.json" `
  --assign-identity

```

To gt the FQDN (fully qualified domain name) of your container

```PowerShell
az container show `
  --resource-group $resourceGroup `
  --name $containerName `
  --query "join('://', ['https', ipAddress.fqdn])" `
  --output "tsv"
```

Navigate to that (but with port 5000) and you should see this

![alt text](image.png)

but it might not actually be healthy

review the logs here, container is running, but it couldn't find the config file:

![alt text](image-1.png)

fixed this by adjusting the command-line for the /cfg file share - make sure that's correct

sql server networking - allows azure service to access this server <-- this was the problem

troubleshooting steps (another post idea?)

- use sql auth instead of managed identity
- test dab-config locally like in the last post

```PowerShell
# Get the principal ID of the container's managed identity
$principalId = az container show --resource-group $resourceGroup --name $containerName --query "identity.principalId" -o tsv

Invoke-DbaQuery -SqlInstance $conn -Database $database -Query ("CREATE USER [{0}] FROM EXTERNAL PROVIDER; ALTER ROLE db_datareader ADD MEMBER [{0}]; ALTER ROLE db_datawriter ADD MEMBER [{0}];" -f $containerName)
```

But you can't create this with a sql login...

> WARNING: [09:11:25][Invoke-DbaQuery] [sqlsvr-dab-prod-001.database.windows.net] Failed during execution | Principal 'ci-dab-prod-001' could not be created. Only connections established with Active Directory accounts can create other Active Directory users.
> Cannot add the principal 'ci-dab-prod-001', because it does not exist or you do not have permission.
> Cannot add the principal 'ci-dab-prod-001', because it does not exist or you do not have permission.

So we need to use external admin that we created, connect and get the token

```PowerShell
Connect-AzAccount # do the auth dance
$azureToken = Get-AzAccessToken -ResourceUrl https://database.windows.net
$connAD = Connect-DbaInstance -SqlInstance ('{0}.database.windows.net' -f $server) -Database $database -AccessToken $azureToken
Invoke-DbaQuery -SqlInstance $connAd -Database $database -Query ("CREATE USER [{0}] FROM EXTERNAL PROVIDER; ALTER ROLE db_datareader ADD MEMBER [{0}]; ALTER ROLE db_datawriter ADD MEMBER [{0}];" -f $containerName)
```







You can view your container in the Azure Portal now and check it's status,

Once this is up and running you can navigate to [http://ci-dab-prod-001.uksouth.azurecontainer.io:5000/](http://ci-dab-prod-001.uksouth.azurecontainer.io:5000/) to check the status of your container

> Managed Identities are super cool, you can enable them for your Azure resources, and then give those resources access to other Azure resources with no passwords to manage. I highly recommend if you aren't using these already you look into them.

need to give the container app MI access to the database

```sql
/****** Object:  User [azqr-func-dev]    Script Date: 19/08/2025 15:05:51 ******/
CREATE USER [ca-cortexapi-dev] FROM  EXTERNAL PROVIDER  WITH DEFAULT_SCHEMA=[dbo]
GO


ALTER ROLE db_datareader ADD MEMBER [ca-cortexapi-dev];
ALTER ROLE db_datawriter ADD MEMBER [ca-cortexapi-dev];
```

check the url shows it's healthy - but we need to mount config file

should get to it now... but no auth!! :o

how hard can that be?!?

## TODO: cli code here\terraform?

