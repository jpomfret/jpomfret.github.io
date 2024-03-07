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

Welcome to another post in the series I'm working on to show off how dbatools can make managing replication easier. If you haven't seen the first two posts you can see the links below:

- [dbatools - introducing replication support](/dbatools-replication)
- [dbatools Replication: The Get commands](/dbatools-repl-get)

This post is focusing on how to setup replication with dbatools, we support all three flavours of replication - snapshot, transactional and even merge replication! Also the steps we'll walk through for setup in this post are very similar no matter which flavour you're implementing.

There are certain steps you have to complete as you're setting up replication, I'll walk through them in this article as dbatools allows us to complete them all. However, I won't go into a lot of details on why or how replication works, or provide guidance on best practices. If you need more information on replication as a technology then I recommend visiting the [Microsoft docs](https://learn.microsoft.com/en-us/sql/relational-databases/replication/sql-server-replication?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655).

## Setup Distributor and Publisher

Alright, step 1, replication requires a server that is configured as a distributor, and a server that is configured as a publisher. 

Good news, these pieces of the puzzle can both be configured on the same server which is what I'll demonstrate in my test environment. In environments where replication has a high throughput and\or requires peak performance you can configure a separate server for distribution to move some of the load off of the publisher.

### Setup Distributor

First, I will use `Enable-DbaReplDistributor` to configure my `sql1` instance as the distributor, this is completed with the following code:

```PowerShell
Enable-DbaReplDistributor -SqlInstance sql1
```

You can see the following output is returned, note that the `DistributionDatabase` property is null, this is what is returned from the [RMO](https://learn.microsoft.com/en-us/sql/relational-databases/replication/concepts/replication-management-objects-concepts?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) command dbatools uses under-the-hood.

There is an optional parameter `-DistributionDatabase` if you want to specify a certain name for the database that is created on the distributor, but if you don't specify the database will be called `distribution` which is the default if you were to create it through SSMS.

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

You can see in the results above that `IsDistributor` returns true now so we are ready to move onto creating our publisher.

### Setup Publisher

Replication is all about publications, and the articles within those publications. Publications are created on a SQL Server that is setup as a publisher, I'll call `Enable-DbaReplPublishing` to configure `sql1` to be a publisher.

```PowerShell
Enable-DbaReplPublishing -SqlInstance sql1
```

The results look very similar to what was returned by `Enable-DbaReplDistributor`, however you can now see the `DistributionDatabase` is populated, and `IsPublisher` has changed to true.

```text
ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : True
IsPublisher          : True
DistributionServer   : SQL1
DistributionDatabase : distribution
```

At this point we have the environment pieces in place in order to create publications, articles and subscriptions.

## Create Publications

Once

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

## Series

This is part of a series of posts covering how to use the dbatools replication commands, other posts in the series:

- [dbatools - introducing replication support](/dbatools-replication)
- [dbatools Replication: The Get commands](/dbatools-repl-get)
- dbatools Replication: Setup replication with dbatools - this post!
- dbatools Replication: Tear down replication with dbatools

You can also view any posts I've written on Replication by heading to the [Replication Category](/categories/replication/) page of this blog.

## Presentation at SQLBits

Also don't forget I'm presenting 'managing replication with dbatools' at SQLBits 2024 in just a couple of weeks!

{{<
  figure src="sqlbits.png"
         alt="I'm Speaking at SQLBits"
         link="https://sqlbits.com/attend/the-agenda/friday/#Managing_replication_with_dbatools"
>}}
