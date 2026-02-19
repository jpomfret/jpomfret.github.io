---
title: "dab - API Endpoints permissions"
slug: "dab-api-permissions"
description: "Post three in my dab series, and here we're going to look at changing our API endpoints from being publically accessible, to require authentication."
date: 2026-02-15T11:00:00Z
categories:
  - dab
  - api
  - PowerShell
tags:
  - dab
  - api
  - PowerShell
image: header.png
draft: true
---

This is post three in my series about the Data API Builder (dab), the first post, [Data API Builder](/dab-api-builder/), covers what dab is and how to test it locally against SQL Server in running in a container. The second post, [Running dab in an Azure Container Instance](/dab-api-container/), starts to productionise this, moving it into the cloud, but with no auth required to hit the endpoints.

In this post we'll look to fix this, specifically by enabling other Azure services to use these endpoints with integrated authentication. If you're looking to follow along you need to have the infra we built in the previous post:

- an Azure SQL Database which is the source
- a Storage Account hosting the `dab-config.json` file
- an Azure Container App running dab

> ✅ My end goal is to be able to insert data into my Azure SQL Database from PowerShell code that's running in an Azure Function. Let's get straight into it.

## Entra App Registration

To be able to create an Azure Function (or another Azure service) that can access the data in the SQL Database via the API endpoints we need to give the Function App a way of authenticating with these endpoints. We'll do this with an App Registration in Entra.

Let's create that app registration, and add the default application id uri for it using Az CLI commands. I've named this `DAB-API-Access` but the name isn't important, I recommend following whatever naming conventions you have in place for these.

```PowerShell
# Create the App Registration
az ad app create --display-name "DAB-API-Access" --sign-in-audience "AzureADMyOrg"

# Get the App ID (Client ID) - you'll need this
$app_id = $(az ad app list --display-name "DAB-API-Access" --query "[0].appId" -o tsv)

# Add the default user_impersonation scope (this is often sufficient)
az ad app update --id $app_id --identifier-uris "api://$app_id"
```

## dab Config File - Configure Authentication

The next step is to update the dab config. First we need to configure an authentication provider. There are several options here, I'm going to use Entra ID, but the Microsoft docs do have [Authentication provider guides](https://learn.microsoft.com/en-us/azure/data-api-builder/concept/security/how-to-authenticate-entra?tabs=bash#authentication-provider-guides).

```PowerShell
dab configure --config .\dab-config.json --runtime.host.authentication.provider EntraID
```

```text
Information: Microsoft.DataApiBuilder 1.6.87
Information: User provided config file: .\dab-config.json
Loading config file from C:\Temp\dab\dab-config.json.
Information: Updated RuntimeConfig with Runtime.Host.Authentication.Provider as 'EntraID'
Information: Successfully updated runtime settings in the config file.
```

You can either run this command like so, passing in the path to the config file with the `--config` parameter, or if you navigate to that folder in your terminal you can exclude that parameter. Let's also set the jwt audience to the ID of our app registration, this will allow our Azure Function to request a token with this audience, and then dab will accept requests using tokens with this specific audience.

```PowerShell
dab configure --config .\dab-config.json --runtime.host.authentication.jwt.audience "$app_id"
```

```text
Information: Microsoft.DataApiBuilder 1.6.87
Information: Config not provided. Trying to get default config based on DAB_ENVIRONMENT...
Information: Environment variable DAB_ENVIRONMENT is (null)
Loading config file from C:\Temp\dab\dab-config.json.
Information: Updated RuntimeConfig with Runtime.Host.Authentication.Jwt.Audience as 'api://691ad7dd-7451-4748-92b1-0da2f288ef0d'
Information: Successfully updated runtime settings in the config file.
```

We also need to configure the jwt issuer, this is our Azure tenant, which again allows dab to check the authenticity of the token in any incoming requests. This time you'll note I dropped the `--config` parameter since I'm working in the same folder in my terminal.

```PowerShell
$tenantId = ($(az account show) | ConvertFrom-Json).tenantId
dab configure --runtime.host.authentication.jwt.issuer "https://sts.windows.net/$tenantId"
```

#TODO docs are wrong on these two

```text
https://login.microsoftonline.com/$tenantId$/v2.0"
Information: Microsoft.DataApiBuilder 1.6.87
Information: Config not provided. Trying to get default config based on DAB_ENVIRONMENT...
Information: Environment variable DAB_ENVIRONMENT is (null)
Loading config file from C:\Temp\dab\dab-config.json.
Information: Updated RuntimeConfig with Runtime.Host.Authentication.Jwt.Issuer as 'https://login.microsoftonline.com/****-tenant-id****-****$/v2.0'
Information: Successfully updated runtime settings in the config file.
```

The authentication piece of my dab-config now looks like so:

```json
"authentication": {
        "provider": "EntraID",
        "jwt": {
          "audience": "api://691ad7dd-7451-4748-92b1-0da2f288ef0d",
          "issuer": "https://login.microsoftonline.com//****-tenant-id****-****$/v2.0"
        }
      },
```

## dab Config File - Configure Entities

We also need to update our entities from anonymous access to only allow authenticated users.

> ⚠️ What's interesting, but when you update permissions it will update an existing role, or add a new role. So if you've followed the previous post your current config already has the 'anonymous' role, and we run an update to add the Authenticated role - the 'anonymous' role will remain with permissions. We also need to update that to not have permissions.

But, we have PowerShell, and the config is a json object so we can easily read in the JSON, manipulate it with PowerShell to remove the permissions for the anonymous role, and then resave the config as JSON.

```PowerShell
# Load the json config file into a PowerShell Object
$configPath = ".\dab-config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json

# Remove anonymous permissions
$config.entities.PSObject.Properties | ForEach-Object {
    $entity = $_.Value
    if ($entity.permissions) {
        $entity.permissions = @($entity.permissions | Where-Object { $_.role -ne "anonymous" })
    }
}

# Save the config
$config | ConvertTo-Json -Depth 100 | Set-Content $configPath
```

Once the anonymous permissions have been cleaned up we can update our entities to add access for authenticated users.

This allows any authenticated user to read and edit the data, there are ways to make this more granular with roles, you can read more in the Microsoft Docs, [add application roles](https://learn.microsoft.com/en-us/azure/data-api-builder/concept/security/how-to-authenticate-entra?tabs=bash#add-app-roles-optional).

```PowerShell
$adminUser ="databaseadmin"
$securePassword = ConvertTo-SecureString "dbatools.IO!" -AsPlainText -Force
$cred = [pscredential]::new($adminUser, $securePassword)

$server = 'sqlsvr-dab-prod-001'
$database = 'sqldb-dab-prod-001'

$conn = Connect-DbaInstance -SqlInstance ('{0}.database.windows.net' -f $server) -SqlCredential $cred
$conn.databases[$database].Tables.ForEach{
    dab update ('{0}_{1}' -f $psitem.schema, $psitem.Name) --permissions "Authenticated:create,read,update"
}
```

After this our entities should look similar to this snippet:

```json
"dbo_BuildVersion": {
      "source": {
        "object": "dbo.BuildVersion",
        "type": "table"
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "dbo_BuildVersion",
          "plural": "dbo_BuildVersions"
        }
      },
      "rest": {
        "enabled": true
      },
      "permissions": [
        {
          "role": "Authenticated",
          "actions": [
            {
              "action": "create"
            },
            {
              "action": "read"
            },
            {
              "action": "update"
            }
          ]
        }
      ]
    },
```

## Upload config to Azure Storage

After the above changes to our `dab-config.json` so it's set for authenticated access, we need to upload this to the storage account we're using.

```PowerShell
$storageAccount = "dabconfigstorage1234"  # Must be globally unique

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

## Test dab - confirm access

First let's restart the container app to pick up new config file that we've uploaded.

```PowerShell
az container restart `
  --resource-group $resourceGroup `
  --name $containerName
```

If you don't still have it handy you can get the FQDN for the dab container app with `az container show`.

```PowerShell
az container show `
  --resource-group $resourceGroup `
  --name $containerName `
  --query "join('', ['http://', ipAddress.fqdn, ':5000'])" `
  --output "tsv"
```

Hitting the returned endpoint should report that the dab container is healthy. But, when I hit one of my endpoints, `http://ci-dab-prod-001.uksouth.azurecontainer.io:5000/api/dbo_BuildVersion` for example to get the data from the `dbo.BuildVersion` table, I get a 403 - unauthorized error.

This is great news, and shows that the dab container app is now using my new `dab-config.json` file that requires authorization to reach my data.

{{<
    figure src="unauthorized.png"
    alt="dab endpoint returns 403, unauthorized message"
>}}

Now let's set up an Azure Function app that is able to authenticate with Entra, and then retrieve my data as an authorized user.

## Tidy Up

If you've been following along you can tidy up and remove the whole resource group with the following command

```PowerShell
az group delete --name $resourceGroup
```

## Up Next

As this post is getting lengthy, I'm going to wrap this up here. In the next post we'll deploy an Azure Function app that can make use of these secure dab endpoints to read and write data.

At this point you can also use any Azure services, or other applications that can authenticate with Entra to interact with the dab API endpoints.

## dab Blog Series

Here are all the links to the dab blog series:

1. [Data API Builder](/dab-api-builder/)
2. [Running dab in an Azure Container Instance](/dab-api-container/)
3. More coming soon...
4. More coming soon...

Or you can view all posts about dab using the [dab](/categories/dab/) category.
