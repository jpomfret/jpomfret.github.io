---
title: "Dbatools Backup -ReplaceInName"
slug: "dbatools-backup-replacename"
description: "ENTER YOUR DESCRIPTION"
date: 2025-03-18T14:30:31Z
categories:
tags:
image:
draft: true
---


https://docs.dbatools.io/Backup-DbaDatabase.html
Direct copy from the docs

> -ReplaceInName
> If this switch is set, the following list of strings will be replaced in the FilePath and Path strings:
> instancename - will be replaced with the instance Name
> servername - will be replaced with the server name
> dbname - will be replaced with the database name
> timestamp - will be replaced with the timestamp (either the default, or the format provided)
> backuptype - will be replaced with Full, Log or Differential as appropriate

then you can specify the backup name - but it's still dynamic!

```PowerShell
Backup-DbaDatabase -SqlInstance Server1\Prod -Path \\filestore\backups\servername\instancename\dbname\backuptype -FilePath dbname-backuptype-timestamp.trn -Type Log -ReplaceInName
```