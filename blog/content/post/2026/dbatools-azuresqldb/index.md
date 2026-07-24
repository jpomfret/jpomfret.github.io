---
title: "Azure SQL Database - Run queries against all databases on an Azure SQL Instance"
slug: "dbatools-azuresql"
description: "Have you ever wanted to run a query against all of the Azure SQL Databases on an instance? This is the post for you, of course, using dbatools!"
date: 2026-07-23T15:00:00Z
categories:
- dbatools
- azure
- powershell
tags:
- dbatools
- azure
- powershell
image: engin-akyurt-gJILnne_HFg-unsplash.jpg
draft: false
---

In the on-prem world, or when we're working with SQL Servers on VMs, wherever they might live it was pretty easy with dbatools to run a query against all the databases, collect some info and collate it into one record set. This used to work with Azure SQL Instances too - but Azure auth, or cloud auth in general is hard and recently the `Connect-DbaInstance` command needed to change to make it more reliable.

So, this is a quick post to cover how we can still manage this.

And, let's be honest, this is for future Jess when I need to do this again (Hi future Jess 👋).

## Connect to Azure

Now it's probably no surprise that step one is to connect to Azure from your PowerShell session and get a token. You can use the Azure CLI, or Azure PowerShell modules for this. I'll use the CLI below.

```PowerShell
# Follow the auth dance
az login
# get a token to use to connect to other resources
$azureToken = (az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
```

Next let's set a variable for the server name, and use `Connect-DbaInstance` to connect. Then we can use these throughout the script.

```PowerShell
$azureSqlInstance = 'serverName.database.windows.net'

$connectParams = @{
    SqlInstance = $azureSqlInstance
    AccessToken = $azureToken
}
$inst = Connect-DbaInstance @connectParams
```

## The old way

You used to be able to use that connection to run queries against any database on the logical instance, but now you get an error.

```PowerShell
$queryParams = @{
    SqlInstance = $inst
    Database    = 'AdventureWorks'
    Query       = 'SELECT DB_NAME()'
}
Invoke-DbaQuery @queryParams
```

This surfaces the following warning, by default dbatools doesn't throw terminating errors, if you want that behaviour you can use the `-EnableException` property on most commands.

> WARNING: [07:11:01][Invoke-DbaQuery] Failure | Property NonPooledConnection cannot be changed or read after a connection string has been set.

This is more secure, and is the way that `Connect-DbaInstance` should work in the cloud, but it did break my script!

## Get a list of databases

But with PowerShell, and dbatools there is always more than one way of doing things. Instead, we can get a list of Azure SQL Databases that are on the logical instance, and then loop through connecting to that database with the access token and running the query you're interested in.

I'm using the [PSFramework](https://github.com/powershellframeworkcollective/psframework) module for the logging, one of my favourites - if you don't have that available, either get it from the PowerShell Gallery, or change to use `Write-Output`.

```PowerShell
# Use Get-DbaDatabase to get a list of databases from the connection we established previously.
$dbParams = @{
    SqlInstance   = $inst
    ExcludeSystem = $true
}
$dbs = Get-DbaDatabase @dbParams

# go through each database, connect, run query

$results = $dbs.foreach{
    $d = $_

    $dbConnectParams = @{
        SqlInstance = $azureSqlInstance
        AccessToken = $azureToken
        Database    = $d.Name
    }
    $dbinst = Connect-DbaInstance @dbConnectParams

    $queryParams = @{
        SqlInstance = $dbinst
        Query       = 'SELECT * FROM dbo.importantTable'
    }
    Invoke-DbaQuery @queryParams

    $messageParams = @{
        Message = ('Query Complete: {0}' -f $d.Name)
        Level   = 'Important'
    }
    Write-PSFMessage @messageParams
}

$results
```

There we go - we can now answer questions about data within all of our databases. I use this often and so I know I'll be back here looking for this code. I hope this is a useful snippet for you also.
