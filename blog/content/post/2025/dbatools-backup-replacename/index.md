---
title: "Dbatools Backup-DbaDatabase -ReplaceInName"
slug: "dbatools-backup-replacename"
description: "Recently I was reading the docs for Backup-DbaDatabase and found a parameter I didn't realise existed, but is so useful when you want to automate backups, but keep control of the file names."
date: 2025-04-13T14:30:31Z
categories:
 - dbatools
 - backups
tags:
 - dbatools
 - backups
image: guillaume-auceps-vffNjorpNrg-unsplash.jpg
draft: false
---

I use [dbatools](https://dbatools.io) all the time, I'm talking literally every workday, but how often do I read the docs? Probably not often enough!

Whenever I'm teaching PowerShell and especially dbatools, I talk about `Get-Help` because without leaving your console, you can review full documentation of the commands. Now, this documentation has to have been added by the author of the command, but we guarantee that for every dbatools command with built in Pester tests!

So, not too long ago, I was writing a script that would be part of a release pipeline. The client wanted to do a quick `COPY_ONLY` backup of all the databases on three instances, before they deployed new application code, which could be making schema changes. Basically, creating an easy rollback plan if the deployment went bad.

Not a problem with `Backup-DbaDatabase`, I already know we can pass in multiple instances, and specify `-CopyOnly` to not interfere with the LSN chain for the regular backups.

The difference was, there was already a specified naming convention for the backups, and we wanted to match that naming with our new automated script.

If I start with the following script, it will perform a `COPY_ONLY` backup of all databases on the `mssql1` instance, to the specified folder `/shared/release`.

```PowerShell
$backupParams = @{
    SqlInstance = "mssql1"
    Path = "/shared/release/v7"
    CopyOnly = $true
}
Backup-DbaDatabase @backupParams
```

You can see we got the files we needed, but using the standard dbatools naming convention of `databaseName_timestamp.bak`.

{{<
    figure src="backupFiles.png"
    alt="ls of backup directory showing backup files"
>}}

For most situations, this is fine and I leave it at that, but how would I manage to change the location to be `/shared/release/v7/mssql1/MSSQLSERVER/pubs.bak`. So the server and instance names are folders, and then the file is just named after the database name?

You could do this in PowerShell, get the list of database, loop through setting the fullname - but instead, if we check the documentation for `Backup-DbaDatabase` we can see this functionality is already built in with the `-ReplaceInName` parameter.

## ReplaceInName Parameter

By checking the help we can see which values can be replaced on the fly.

```PowerShell
Get-Help Backup-DbaDatabase
```

This is straight from the docs, and if you want to read it in the online version you can head to [docs.dbatools.io](https://docs.dbatools.io/Backup-DbaDatabase.html).

```text
-ReplaceInName [<Switch>]
  If this switch is set, the following list of strings will be replaced in the FilePath and   Path strings:
    instancename - will be replaced with the instance Name
    servername - will be replaced with the server name
    dbname - will be replaced with the database name
    timestamp - will be replaced with the timestamp (either the default, or the format provided)
    backuptype - will be replaced with Full, Log or Differential as appropriate
```

So, with this information, we can change the script to look like this. Using the keywords `servername`, `instancename` and `dbname` in the parameter values, and including the `ReplaceInName` switch.

```PowerShell
$backupParams = @{
    SqlInstance = "mssql1"
    Path = "/shared/release/v7/servername/instancename"
    FilePath = "dbname.bak"
    ReplaceInName = $true
    CopyOnly = $true
}
Backup-DbaDatabase @backupParams
```

The results will look like this, which is exactly what we needed. Now obviously, depending on what you want the file names to be, these keywords might not be enough, but they give you a decent amount of flexibility to customise the output.

{{<
    figure src="backupFilesNames.png"
    alt="ls of backup folder after using -ReplaceInName param"
>}}

Hope you find this one useful, and it's a good reminder for all of us to read the docs! There is so much functionality in dbatools, none of us know everything this module is capable of!

Header image by [Guillaume Auceps](https://unsplash.com/@gauceps?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash) on [Unsplash](https://unsplash.com/photos/a-row-of-boats-floating-on-top-of-a-body-of-water-vffNjorpNrg?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash).
