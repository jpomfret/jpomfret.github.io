---
title: "Dab Api Azure Func Auth"
slug: "dab-api-azure-func-auth"
description: "ENTER YOUR DESCRIPTION"
date: 2025-08-21T09:14:40Z
categories:
tags:
image:
draft: true
---

This is post three in my series about the Data API Builder (dab), the first post, [Data API Builder](/dab-api-builder/), covers what dab is and how to test it locally against SQL Server in running in a container. The second post, [Running dab in an Azure Container Instance](/dab-api-container/), starts to productionise this, moving it into the cloud, but with no auth required to hit the endpoints.

In this post we'll look to fix this, specifically by enabling other Azure services to use these endpoints with authentication. If you're looking to follow along you need to have the infra we built in the previous post:

- an Azure SQL Database which is the source
- a Storage Account hosting the `dab-config.json` file
- an Azure Container App running dab

My end goal is to be able to insert data into my Azure SQL Database from PowerShell code that's running in an Azure Function. Let's get straight into it.

## Entra App Registration

If the goal is to create an Azure Function (or another Azure service) that can access the data in the SQL Database vai the API endpoints we need to give the Function App a way of authenticating with these endpoints. We'll do this with an App Registation in Entra.

Let's create that app registration.

    ```powershell
    # Create the App Registration
    az ad app create --display-name "DAB-API-Access" --sign-in-audience "AzureADMyOrg"

    # Get the App ID (Client ID) - you'll need this
    $app_id = $(az ad app list --display-name "DAB-API-Access" --query "[0].appId" -o tsv)

    # Add the default user_impersonation scope (this is often sufficient)
    az ad app update --id $app_id --identifier-uris "api://$APP_ID"
    #that last line didn't work but added in the portal
    ```

## dab Config File

Update the dab config to azure auth and cors

```PowerShell
# Set the authentication provider
dab configure --runtime.host.authentication.provider EntraID

# Set the expected audience (Application ID URI)
dab configure --runtime.host.authentication.jwt.audience "api://$APP_ID"

# Set the expected issuer (your tenant)
$tenantId = ($(az account show) | ConvertFrom-Json).id
dab configure --runtime.host.authentication.jwt.issuer "https://login.microsoftonline.com/$tenantId$/v2.0"
```

this is left over json does it match?
```json
    "host": {
      "cors": {
        "origins": ["https://azqr-func-jp-dev-e5gxevfjgbhfhmdk.westeurope-01.azurewebsites.net"],
        "allow-credentials": true
      },
      "authentication": {
        "provider": "AzureAD",
        "jwt": {
          "audience": "ffa9ce65-fe37-4958-849c-8747e106577d",
          "issuer": "https://sts.windows.net/8f5c8fb3-b610-4233-8284-63a7254f4029/"
        }
      },
      "mode": "development"
    }
```

We also need to update our entities from anonomous acces to only allow authenticated users

```
$adminUser ="databaseadmin"
$securePassword = ConvertTo-SecureString "dbatools.IO!" -AsPlainText -Force
$cred = [pscredential]::new($adminUser, $securePassword)

$server = 'sqlsvr-dab-prod-001'
$database = 'sqldb-dab-prod-001'

$conn = Connect-DbaInstance -SqlInstance ('{0}.database.windows.net' -f $server) -SqlCredential $cred
$conn.databases[$database].Tables.ForEach{
    dab update ('{0}_{1}' -f $psitem.schema, $psitem.Name) --permissions "Authenticated:read"
}
```

This will change the entities to require auth? does it? still has the anonomous in there too?

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
          "role": "anonymous",
          "actions": [
            {
              "action": "read"
            }
          ]
        },
        {
          "role": "Authenticated",
          "actions": [
            {
              "action": "read"
            }
          ]
        }
      ]
    },
```

TODO why mode dev? gives us swagger and other dev tools

any authenticated user can access - there is a way of doing roles like `DAB.Read` to make it more granular

this changes the entity from anon access to authenticated

```json
"azqr_cost": {
      "source": {
        "object": "dbo.azqr_cost",
        "type": "table"
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "azqr_cost",
          "plural": "azqr_costs"
        }
      },
      "rest": {
        "enabled": true
      },
      "permissions": [
        {
          "role": "authenticated",
          "actions": ["read"]
        }
      ]
    }
```

1. create function

move variables to the top

```PowerShell
$resourceGroup = 'rg-dab-prod-001'
$storageAccount = "dabconfigstorage1234"  # Must be globally unique
$functionAppName = "func-dab-prod-001"


az functionapp create `
  --resource-group $resourceGroup `
  --name $functionAppName `
  --storage-account $storageAccount `
  --consumption-plan-location $location `
  --runtime powershell `
  --runtime-version 7.4 `
  --functions-version 4 `
  --os-type Windows
```

TODO: need the code in the function to get the token and hit DAB

enable managed identity on function

    ```powershell
    # Enable system-assigned managed identity
    az functionapp identity assign --name $functionAppName --resource-group $resourceGroup
    ```

    ```text
    {
      "principalId": "a0a7dac7-da1e-4478-ac83-e8fbd75f2265",
      "tenantId": "f98042ad-9bbc-499d-adb4-17193696b9a3",
      "type": "SystemAssigned",
      "userAssignedIdentities": null
    }
    ```

1. add app settings

Get the function FQDN
```PowerShell
$containerFQDN = az container show `
  --resource-group $resourceGroup `
  --name $containerName `
  --query "join('', ['http://', ipAddress.fqdn, ':5000'])" `
  --output "tsv"

#TODO: get this
$clientId = 'a0a7dac7-da1e-4478-ac83-e8fbd75f2265'
```

```powershell
  az functionapp config appsettings set `
  --name $functionAppName `
  --resource-group $resourcegroup `
  --settings `
    "DAB_ENDPOINT=$containerFQDN" \
    "AZURE_CLIENT_ID=$clientID"
```

1. then give the function MI access to get tokens

in entra

- add app role 'Cortex DAB'
- add a scope
- add a authorized application - added wrong id ,  doesn't work for function mi id

```bash
az ad app permission add \
  --id 161e0a85-54fe-4472-9a5d-409cc5dcb14f \
  --api ffa9ce65-fe37-4958-849c-8747e106577d \
  --api-permissions "api://ffa9ce65-fe37-4958-849c-8747e106577d/Cortex.Read.All=Scope"
```

TODO: is this needed if we don't use scope?



need to give the container app MI access to the database

```sql
/****** Object:  User [azqr-func-dev]    Script Date: 19/08/2025 15:05:51 ******/
CREATE USER [ca-cortexapi-dev] FROM  EXTERNAL PROVIDER  WITH DEFAULT_SCHEMA=[dbo]
GO


ALTER ROLE db_datareader ADD MEMBER [ca-cortexapi-dev];
ALTER ROLE db_datawriter ADD MEMBER [ca-cortexapi-dev];
```

check the url shows it's healthy - but we need to mount config file





## Tidy Up

If you've been following along you can tidy up and remove the whole resource group with the following command

```PowerShell
az group delete --name $resourceGroup
```

## Up Next

troubleshooting?

## dab Blog Series

Here are all the links to the dab blog series:

1. [Data API Builder](/dab-api-builder/)
2. [Running dab in an Azure Container Instance](/dab-api-container/)
3. More coming soon...

Or you can view all posts about dab using the [dab](/categories/dab/) category.
