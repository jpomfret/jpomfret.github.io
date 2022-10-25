---
title: "Log Shipping – Pre-stage database backups with dbatools"
description: Log shipping is a SQL Server feature used for disaster-recovery where the transaction log backups are ‘shipped’ from your production instance to a secondary instance.
date: "2022-05-24"
categories:
  - "dbatools"
  - "powershell"
tags:
  - "dbatools"
  - "log-shipping"
  - "powershell"
image: "cover.jpg"
slug: log-ship-staged
---

Log shipping is a SQL Server feature used for disaster-recovery where the transaction log backups are ‘shipped’ from your production instance to a secondary instance. This enables you to cutover to this secondary server in the event of a disaster where you lose your primary instance. Log shipping is not a new feature but is still quite popular.

Recently I was tasked with setting up Log Shipping for a reasonably large production database. I didn’t want to initialize the secondary database with a new full backup as I was already taking full and log backups of the database. In this case we have the option of initialising the database by restoring the full & log backups up to the latest point in time and then configuring log shipping.

## Which backups to restore?

In order for us to stage the database on the secondary at the point in time where we can configure log shipping we need to get the last full backup and any log backups taken since then.  If we were using differential backups as part of our strategy we would need the last full, the latest differential, and any log backups since then.

This could be a lot of backup files to find, put in the right order, and then restore (with no recovery) onto the secondary server. dbatools makes this so easy! We can use `Get-DbaDbBackupHistory` with the `-Last` switch to get the latest backup chain. Then by piping that to `Restore-DbaDatabase` we can automatically restore each piece of the puzzle. First, the full backups and then any differentials or log backups we need to get us to the point in time we are now.

Get-DbaDbBackupHistory -SqlInstance mssql1 -Database productionDb -Last |
Restore-DbaDatabase -SqlInstance mssql2 -NoRecovery -UseDestinationDefaultDirectories

Depending on how long the restores take you might have new log backups to apply to the secondary database, like those that have been taken on the primary since we ran the last command.  Again, we can use dbatools to help us with this. I will execute the same call to `Get-DbaDbBackupHistory` to get the last backup chain, but instead of piping it straight to `Restore-DbaDatabase` I will use `Out-GridView` with the `-PassThru` switch to effectively create a GUI window where I can select the backups I want to restore (any since the last log backup we applied), and then pass them on down the pipeline to be restored by `Restore-DbaDatabase`.

```PowerShell
Get-DbaDbBackupHistory -SqlInstance mssql1 -Database productionDb -Last |
Out-GridView -PassThru |
Restore-DbaDatabase -SqlInstance mssql2 -NoRecovery -UseDestinationDefaultDirectories -Continue
```

## Check on what we restored

Once the restores are complete we can view what was restored using `Get-DbaDbRestoreHistory`.

```PowerShell
Get-DbaDbRestoreHistory -SqlInstance mssql2 -Database productionDb -Last
```

## What’s next?

At this point our secondary database has been initalised and we’re ready to set up log shipping. You can use the GUI in SSMS for this, or I’d recommend taking a look at dbatools offering `Invoke-DbaDbLogShipping`.
