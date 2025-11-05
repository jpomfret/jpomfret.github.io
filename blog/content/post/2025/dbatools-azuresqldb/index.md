---
title: "Dbatools Azuresqldb"
slug: "dbatools-azuresqldb"
description: "ENTER YOUR DESCRIPTION"
date: 2025-10-31T15:34:05Z
categories:
tags:
image:
draft: true
---

You have to connect to each database you can't just use one connection item

```PowerShell
$inst = connect-DbaInstance -SqlInstance 'clouddba-dev.database.windows.net' -AccessToken $azureToken
Invoke-DbaQuery -SqlInstance $inst -Database dmmportal_stark -Query 'select db_name()'
```

This fails with

> WARNING: [15:16:43][Invoke-DbaQuery] Failure | Property NonPooledConnection cannot be changed or read after a connection string has been set.

```PowerShell
# connect to master to get databases
$inst = connect-DbaInstance -SqlInstance 'clouddba-prd.database.windows.net' -AccessToken $azureToken
$dbs = Get-DbaDatabase -SqlInstance $inst  -ExcludeSystem -ExcludeDatabase master, dmmportal_master_dev, dmmportal_shadow

# go through each database, connect, run query
$dbs.foreach{
    $d = $_
    $dbinst = connect-DbaInstance -SqlInstance 'clouddba-dev.database.windows.net' -AccessToken $azureToken -Database $d.name
    Invoke-DbaQuery -SqlInstance $dbinst -Query "CREATE USER [azqr-func-prd] FOR EXTERNAL PROVIDER;EXEC sp_addrolemember N'db_datareader', N'azqr-func-prd';EXEC sp_addrolemember N'db_datawriter', N'azqr-func-prd';"
}
```
