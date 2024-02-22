---
title: "dbatools replication - setup replication"
slug: "dbatools-repl-setup"
description: "Lets take a look at how to setup some replication publications, add articles and create subscriptions all with dbatools."
date: 2024-02-28T10:31:19Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image:
draft: true
---



# enable distribution
```PowerShell
Enable-DbaReplDistributor -SqlInstance sql1
```

```
PS > Enable-DbaReplDistributor -SqlInstance sql1
ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : True
IsPublisher          : False
DistributionServer   : SQL1
DistributionDatabase :
```
Now IsDistributor is true

# enable publishing
Enable-DbaReplPublishing -SqlInstance sql1

```text
Enable-DbaReplPublishing -SqlInstance sql1

ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : True
IsPublisher          : True
DistributionServer   : SQL1
DistributionDatabase : distribution
```

(now IsPublisher is true also)


## Add Publication

```PowerShell
# add a transactional publication
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'testPub'
    Type        = 'Transactional'
}
New-DbaReplPublication @pub
```

```text
ComputerName  : sql1
InstanceName  : MSSQLSERVER
SQLInstance   : [sql1]
DatabaseName  : AdventureWorksLT2022
Name          : testPub
Type          : Transactional
Articles      : {}
Subscriptions : {}
```

## Add article

```PowerShell
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
    Filter      = "lastname = 'gates'"
}
Add-DbaReplArticle @article
```

```text
ComputerName      : sql1
InstanceName      : MSSQLSERVER
SqlInstance       : [sql1]
DatabaseName      : AdventureWorksLT2022
PublicationName   : testPub
Name              : customer
Type              : LogBased
VerticalPartition : False
SourceObjectOwner : SalesLT
SourceObjectName  : Customer
```

## Add a subscrition

```PowerShell
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    PublicationName       = 'testpub'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub
```

note: doesn't return anything


# start snapshot agent
Get-DbaAgentJob -SqlInstance sql1 -Category repl-snapshot | Start-DbaAgentJob

```
ComputerName           : sql1
InstanceName           : MSSQLSERVER
SqlInstance            : sql1
Name                   : SQL1-AdventureWorksLT2022-mergey-2
Category               : REPL-Snapshot
OwnerLoginName         : SQLBITS2024\sqladmin
CurrentRunStatus       : Executing
CurrentRunRetryAttempt : 0
Enabled                : True
LastRunDate            : 1/1/0001 12:00:00 AM
LastRunOutcome         : Unknown
HasSchedule            : True
OperatorToEmail        :
CreateDate             : 2/18/2024 3:11:26 PM

ComputerName           : sql1
InstanceName           : MSSQLSERVER
SqlInstance            : sql1
Name                   : SQL1-AdventureWorksLT2022-snappy-3
Category               : REPL-Snapshot
OwnerLoginName         : SQLBITS2024\sqladmin
CurrentRunStatus       : Executing
CurrentRunRetryAttempt : 0
Enabled                : True
LastRunDate            : 1/1/0001 12:00:00 AM
LastRunOutcome         : Unknown
HasSchedule            : True
OperatorToEmail        :
CreateDate             : 2/18/2024 3:11:29 PM

ComputerName           : sql1
InstanceName           : MSSQLSERVER
SqlInstance            : sql1
Name                   : SQL1-AdventureWorksLT2022-testPub-1
Category               : REPL-Snapshot
OwnerLoginName         : SQLBITS2024\sqladmin
CurrentRunStatus       : Executing
CurrentRunRetryAttempt : 0
Enabled                : True
LastRunDate            : 1/1/0001 12:00:00 AM
LastRunOutcome         : Unknown
HasSchedule            : True
OperatorToEmail        :
CreateDate             : 2/18/2024 3:10:24 PM
```

## replication monitor shows it's working

## demo of adding a row?