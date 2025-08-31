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

part 3!

we have api builder in a container - nice - but it's got anonymous access so any one can wander in - fine for sample data.. not fine for business data

so set up auth

1. create app registration

    ```powershell
    # Create the App Registration
    az ad app create
    --display-name "DAB-API-Access"
    --sign-in-audience "AzureADMyOrg"

    # Get the App ID (Client ID) - you'll need this
    APP_ID=$(az ad app list --display-name "DAB-API-Access" --query "[0].appId" -o tsv)

    # Add the default user_impersonation scope (this is often sufficient)
    az ad app update --id $APP_ID --identifier-uris "api://$APP_ID"
    #that last line didn't work but added in the portal
    ```

1. update the dab config to azure auth and cors

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

TODO why mode dev?

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

TODO: need the code in the function to get the token and hit DAB

1. enable managed identity on function

    ```powershell
    # Enable system-assigned managed identity
    az functionapp identity assign --name "azqr-func-jp-dev" --resource-group "azqr-func-jp-dev_group"
    ```

    ```text
    {
    "principalId": "161e0a85-54fe-4472-9a5d-409cc5dcb14f",
    "tenantId": "8f5c8fb3-b610-4233-8284-63a7254f4029",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
    }
    ```

1. add app settings

```bash
az functionapp config appsettings set \
  --name "azqr-func-jp-dev" \
  --resource-group "azqr-func-jp-dev_group" \
  --settings \
    "DAB_ENDPOINT=https://ca-cortexapi-dev-001.purpleglacier-eca8c529.westeurope.azurecontainerapps.io" \
    "AZURE_CLIENT_ID=ffa9ce65-fe37-4958-849c-8747e106577d"
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
