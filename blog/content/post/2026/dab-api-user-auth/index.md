---
title: "DAB API - User Authentication from Azure CLI"
slug: "dab-api-user-auth"
description: "ENTER YOUR DESCRIPTION"
date: 2025-08-21T09:14:40Z
categories:
  - DAB
  - api
  - PowerShell
tags:
  - DAB
  - api
  - PowerShell
image: header.png
draft: true
---

This is post four in my series about the Data API Builder (DAB), the first post, [Data API Builder](/dab-api-builder/), covers what DAB is and how to test it locally against SQL Server in running in a container. The second post, [Running DAB in an Azure Container Instance](/dab-api-container/), starts to productionise this, moving it into the cloud, but with no auth required to hit the endpoints. Then in the last post, [DAB API - Authenticated API Endpoints](/dab-api-add-auth), we locked down the endpoints, they now require authentication to interact with the data.

In this post we'll walk through how to authenticate with Entra from the Microsoft Azure CLI and then access our API endpoints to get some data.

If you're looking to follow along you need to have the infra we built in the previous two posts, [Running DAB in an Azure Container Instance](/dab-api-container) and [DAB API - Authenticated API Endpoints](/dab-api-add-auth):

- an Azure SQL Database which is the source
- a Storage Account hosting the `dab-config.json` file
- an Azure Container App running DAB
- an Entra App Registration & Enterprise Application

At this point your containerized instance of DAB should be running, and healthy. However, if I call the DAB API endpoint without authentication I get a 401 error.

```PowerShell
$data = Invoke-RestMethod -Uri 'http://ci-dab-prod-001.uksouth.azurecontainer.io:5000/api/dbo_BuildVersion'
$data.value
```

## Entra User Authentication

Let's look at how I can authenticate with my Entra user to get a token and access the DAB endpoints to retrieve data. There is one more setup step to configure this to work properly.

### Update Entra App registration for Authentication

We do already have an app role configured, but those only get us application tokens — that's the route we'll use in the next post when the function calls the API as itself. But Azure CLI is signing in as me, so Entra issues a user token instead, and user permissions use a different claim: `scp` rather than roles. Therefore we need to expose at least one delegated scope on the API before the CLI has anything valid to ask for.

We also need to pre-authorize the Azure CLI to request tokens for our DAB API. The authentication flow we'll use will require the client to be authorized, and the Azure CLI doesn't provide a consent UI. Since we already know the scope ID we're creating, we can do both in a single PATCH to the Graph API.

This looks complicated but lets break down the body variable, which is the JSON of our Graph API request into three pieces:

1. `oauth2PermissionScopes` - adding the user authentication
2. `preAuthorizedApplications` - preauthorising the Azure CLI
3. `requestedAccessTokenVersion` is set to 1 because the function uses 1 and we have to choose the same token version

```PowerShell
$azureCliAppId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46" # Microsoft Azure CLI
$existingApp = az ad app show --id $app_id | ConvertFrom-Json

$newScopeId = [guid]::NewGuid().ToString()
$body = @{
    api = @{
        oauth2PermissionScopes = @(
            @{
                id = $newScopeId
                value = "user_impersonation"
                type = "User"
                isEnabled = $true
                adminConsentDisplayName = "Access DAB API as user"
                adminConsentDescription = "Allow the application to access DAB API on behalf of the signed-in user"
                userConsentDisplayName = "Access DAB API as you"
                userConsentDescription = "Allow the application to access DAB API on your behalf"
            }
        )
        preAuthorizedApplications = @(
            @{
                appId = $azureCliAppId
                delegatedPermissionIds = @($newScopeId)
            }
        )
        requestedAccessTokenVersion = 1
    }
}

# Compress avoids newlines; escape double quotes for the shell
$bodyJson = ($body | ConvertTo-Json -Depth 10 -Compress) -replace '"', '\"'

az rest --method PATCH `
  --uri "https://graph.microsoft.com/v1.0/applications/$($existingApp.id)" `
  --headers "Content-Type=application/json" `
  --body "$bodyJson"
```

You can verify this in the portal, within Entra on our Enterprise Application (you might need to search by `$APP_ID` since this was newly created), under `Expose an API` you should see a scope and an authorized client application.

![alt text](image-9.png)

If you didn't do this step, or something above isn't set correctly you'll get the following error, which is quite helpful in that it tells you the scope (your app id) and the Azure CLI App ID you need to solve the problem.

> Authentication failed
> invalid_client: AADSTS650057: Invalid resource. The client has requested access to a resource which is not listed in the requested permissions in the client's application registration. Client app ID: 04b07795-8ddb-461a-bbee-02f9e1bf7b46(Microsoft Azure CLI). Resource value from request: api://4834e86a-398b-4992-bd46-f8f827c02560. Resource app ID: 4834e86a-398b-4992-bd46-f8f827c02560. List of valid resources from app registration: . Trace ID: 0d114f90-7a24-40d4-bf84-10d7b2522300 Correlation ID: 211a8fae-9ed4-4d35-a086-f37aba4f6522 Timestamp: 2026-04-08 05:58:45Z. ($error_uri)

## Test

Now everything is in place we should be able to login to Azure using the Azure CLI, get a token, and then use that token for our API call to our DAB endpoint. Let's test it out.

```PowerShell
az login --tenant $tenantId --scope "api://$app_ID/.default"

# Get a new token (should now be v1.0)
#$app_id = (az ad app create --display-name "DAB-API-Access" --sign-in-audience "AzureADMyOrg" | ConvertFrom-Json).appId
$token = (az account get-access-token --resource "api://$app_id" | ConvertFrom-Json).accessToken

# Verify it's v1.0
$tokenParts = $token.Split('.')
$payload = $tokenParts[1]
while ($payload.Length % 4 -ne 0) { $payload += '=' }
$decodedBytes = [System.Convert]::FromBase64String($payload)
$decodedJson = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
$tokenClaims = $decodedJson | ConvertFrom-Json
Write-Host "Issuer: $($tokenClaims.iss)"  # Should be https://sts.windows.net/tenant-id/

# Test the API
$headers = @{ 'Authorization' = "Bearer $token" }
Invoke-RestMethod -Uri 'http://ci-dab-prod-001.uksouth.azurecontainer.io:5000/api/dbo_BuildVersion' -Headers $headers
```

![alt text](image-5.png)