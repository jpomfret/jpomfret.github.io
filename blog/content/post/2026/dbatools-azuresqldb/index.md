---
title: "Azure SQL Database - Run queries against all databases on the Azure SQL Instance"
slug: "dbatools-azuresql"
description: "Have you ever wanted to run a query against all of the Azure SQL Databases on an instance? This is the post for you, of course, using dbatools!"
date: 2025-10-31T15:34:05Z
categories:
- dbatools
- azure
- powershell
tags:
- dbatools
- azure
- powershell
image:
draft: true
---

In the on-prem world, or when we're working with SQL Servers on VMs, where ever they might live it was pretty easy with dbatools to run a query against all the databases, collect some info and collate it into one record set. This used to work with Azure SQL Instances too - but Azure\cloud auth is hard and recently the `Connect-DbaInstance` command needed to change to make it more reliable.

So, this is a quick post to cover how we can still manage this.

And, let's be honest, this is for future Jess when I need to do this again (Hi future Jess 👋).

## Connect to Azure

Now it's probably no surprise that step one is to connect to Azure from your PowerShell session - you can either use the Azure CLI, or Azure PowerShell modules for this, I'll use the CLI below.

```PowerShell
# Follow the auth dance
az login
# get a token to use to connect to other resources
$azureToken = (az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
```

## Get a list of databases

Let's use `Get-DbaDatabase` to get a list of databases

You have to connect to each database you can't just use one connection item

```PowerShell
$inst = connect-DbaInstance -SqlInstance 'clouddba-prd.database.windows.net' -AccessToken $azureToken
Invoke-DbaQuery -SqlInstance $inst -Database dmmportal_stark -Query 'select db_name()'
```

This fails with

> WARNING: [15:16:43][Invoke-DbaQuery] Failure | Property NonPooledConnection cannot be changed or read after a connection string has been set.

```PowerShell
# connect to master to get databases
$instName = 'clouddba-prd.database.windows.net'
$inst = connect-DbaInstance -SqlInstance $instName -AccessToken $azureToken
$dbs = Get-DbaDatabase -SqlInstance $inst  -ExcludeSystem -ExcludeDatabase master, dmmportal_master_prd

# go through each database, connect, run query
$dbs[0].foreach{
    $d = $_
    $dbinst = connect-DbaInstance -SqlInstance $instName -AccessToken $azureToken -Database $d.name
    Invoke-DbaQuery -SqlInstance $dbinst -Query "DROP USER [azqr-func-prd]; CREATE USER [azqr-func-prd] FOR EXTERNAL PROVIDER;EXEC sp_addrolemember N'db_datareader', N'azqr-func-prd';EXEC sp_addrolemember N'db_datawriter', N'azqr-func-prd';"
    Write-PSFMessage -Message ('Query Complete: {0}' -f $d.Name) -Level Important
}
```
