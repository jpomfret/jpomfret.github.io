# Ideas

## Find all Open PRs in Azure DevOps

```PowerShell
##############################################################################################################
## Name: Get Open PRs
## Original Author: Jess Pomfret (Data Masterminds)
## Date: Oct 2024
## Description: This script gets all open PRs, across all repositories, in a given Azure DevOps project.
##############################################################################################################

# connect to Azure and get a token
$token = (Get-AzAccessToken -AsSecureString:$false).Token

$headers = @{"Authorization"="Bearer $token"}

$baseurl = ("https://dev.azure.com/{0}/{1}/_apis" -f 'InVentry-Development','InVentry%20V5')
write-host ('the base url is {0}' -f $baseurl)

$repositories = (Invoke-RestMethod -Uri ("{0}/git/repositories?api-version=7.1" -f $baseurl, $repositoryID) -Method GET -Headers $headers).Value | Select-Object *

$repositories | Select-Object name, id

$prs = @()
$repositories.foreach{
    $prs += (Invoke-RestMethod -Uri ("{0}/git/repositories/{1}/pullrequests?api-version=7.1" -f $baseurl, $_.id) -Method GET -Headers $headers).Value | Select-Object *
}

$prs | Select-Object @{l='Repository';e={$_.repository.name}}, title, status, @{l='CreatedBy';e={$_.createdBy.displayName}}, creationDate, url
```