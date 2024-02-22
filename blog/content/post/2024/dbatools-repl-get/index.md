---
title: "dbatools replication - the get commands"
slug: "dbatools-repl-get"
description: "This post will show off all the `Get-` commands that are available within dbatools for replication."
date: 2024-02-21T10:31:19Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image:
draft: true
---

Welcome to the second post in this series on dbatools replication support. This post will show off all the `Get-` commands that are available within dbatools for replication. When you're using PowerShell, and especially if you're new to PowerShell, exploring the `Get-` commands for a certain module, or area are a great way to get started. As it says in the name, these commands get information about something, they aren't going to change anything, which means they are pretty safe to run in your environment. Of course, I'm always going to say, you should still run these in your test environment first to make sure you understand what they are doing, and how they behave in your specific environment.

As we were building in support for replications to dbatools, we started by building these `Get-` commands, this gave us a good way of exploring the [Replication Management Objects (RMO)](https://learn.microsoft.com/en-us/sql/relational-databases/replication/concepts/replication-management-objects-concepts?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) and understanding how they worked. We also wanted to make sure that we could get all the information we needed to be able to build the other commands that would be needed to manage replication.

I'm going to split this post up into three sections - the first will look at the server level commands, the second will look at publications and subscriptions, and then finally we'll look more closely at articles. If you're not familiar with how replication works within SQL Server I'd recommend reviewing the [Microsoft docs](https://learn.microsoft.com/en-us/sql/relational-databases/replication/sql-server-replication?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) to familiarise yourself with the basic topology and the terminology for the pieces and parts involved.

## Server level commands

In order for replication to be setup there needs to be a publisher and a distributor. I will show how to set these up with dbatools in the next post, but for now we can use the `Get-` commands to see what is already setup in our environment.

```PowerShell
Get-DbaReplServer -SqlInstance sql1
```

PS > Get-DbaReplServer -SqlInstance sql1

ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : True
IsPublisher          : True
DistributionServer   : SQL1
DistributionDatabase : distribution

Returns type TypeName: `Microsoft.SqlServer.Replication.ReplicationServer`


```PowerShell
Get-DbaReplDistributor -SqlInstance sql1
```

```
PS > Get-DbaReplDistributor -SqlInstance sql1

ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsPublisher          : True
IsDistributor        : True
DistributionServer   : SQL1
DistributionDatabase : distribution
DistributorInstalled : True
DistributorAvailable : True
HasRemotePublisher   : False
```

Also Returns type TypeName: `Microsoft.SqlServer.Replication.ReplicationServer` but with more distribution specific properties - you could get these from `Get-DbaReplServer` but we're trying to make this as intuitive as possible so added this additional command.





```PowerShell
Get-DbaReplPublisher -SqlInstance sql1
```

```
PS > Get-DbaReplPublisher -SqlInstance sql1

ComputerName             : sql1
InstanceName             : MSSQLSERVER
SqlInstance              : sql1
Status                   : Active
WorkingDirectory         : C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\ReplData
DistributionDatabase     : distribution
DistributionPublications : {}
PublisherType            : MSSQLSERVER
Name                     : SQL1
```

Returns  `TypeName: Microsoft.SqlServer.Replication.DistributionPublisher`

For more information and examples for each of these commands, check out the dbatools help documentation:

- [Get-DbaReplServer](https://dbatools.io/Get-DbaReplServer)
- [Get-DbaReplDistributor](https://dbatools.io/Get-DbaReplDistributor)
- [Get-DbaReplPublisher](https://dbatools.io/Get-DbaReplPublisher)

## Publications and Subscriptions

```PowerShell
# view publications
Get-DbaReplPublication -SqlInstance sql1

```

```text

ComputerName  : sql1
InstanceName  : MSSQLSERVER
SQLInstance   : [sql1]
DatabaseName  : AdventureWorksLT2022
Name          : snappy
Type          : Snapshot
Articles      : {address}
Subscriptions : {SQL2:AdventureWorksLT2022Snap}

ComputerName  : sql1
InstanceName  : MSSQLSERVER
SQLInstance   : [sql1]
DatabaseName  : AdventureWorksLT2022
Name          : testPub
Type          : Transactional
Articles      : {customer}
Subscriptions : {SQL2:AdventureWorksLT2022}

ComputerName  : sql1
InstanceName  : MSSQLSERVER
SQLInstance   : [sql1]
DatabaseName  : AdventureWorksLT2022
Name          : mergey
Type          : Merge
Articles      : {product}
Subscriptions : {sql2:AdventureWorksLT2022Merge}
```

```PowerShell
# get subscriptions
Get-DbaReplSubscription -SqlInstance sql1
```

```text
ComputerName       : sql1
InstanceName       : MSSQLSERVER
SqlInstance        : sql1
DatabaseName       : AdventureWorksLT2022
PublicationName    : snappy
Name               : SQL2:AdventureWorksLT2022Snap
SubscriberName     : SQL2
SubscriptionDBName : AdventureWorksLT2022Snap
SubscriptionType   : Push

ComputerName       : sql1
InstanceName       : MSSQLSERVER
SqlInstance        : sql1
DatabaseName       : AdventureWorksLT2022
PublicationName    : testPub
Name               : SQL2:AdventureWorksLT2022
SubscriberName     : SQL2
SubscriptionDBName : AdventureWorksLT2022
SubscriptionType   : Push

ComputerName       : sql1
InstanceName       : MSSQLSERVER
SqlInstance        : sql1
DatabaseName       : AdventureWorksLT2022
PublicationName    : mergey
Name               : sql2:AdventureWorksLT2022Merge
SubscriberName     : sql2
SubscriptionDBName : AdventureWorksLT2022Merge
SubscriptionType   : Push
```

For more information and examples for each of these commands, check out the dbatools help documentation:

- [Get-DbaReplPublication](https://dbatools.io/Get-DbaReplPublication)
- [Get-DbaReplSubscription](https://dbatools.io/Get-DbaReplSubscription)

## Articles

For more information and examples for each of these commands, check out the dbatools help documentation:

# view articles


```PowerShell
Get-DbaReplArticle -SqlInstance sql1
```

```text
ComputerName      : sql1
InstanceName      : MSSQLSERVER
SqlInstance       : [sql1]
DatabaseName      : AdventureWorksLT2022
PublicationName   : snappy
Name              : address
Type              : LogBased
VerticalPartition : False
SourceObjectOwner : SalesLT
SourceObjectName  : Address

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

ComputerName      : sql1
InstanceName      : MSSQLSERVER
SqlInstance       : [sql1]
DatabaseName      : AdventureWorksLT2022
PublicationName   : mergey
Name              : product
Type              : TableBased
VerticalPartition : False
SourceObjectOwner : SalesLT
SourceObjectName  : Product
```

- [Get-DbaReplArticle](https://dbatools.io/Get-DbaReplArticle)
- [Get-DbaReplArticleColumn](https://dbatools.io/Get-DbaReplArticleColumn)

## Bonus content

One of the things I really love about PowerShell and dbatools is it use of objects, when you return output from a command you don't just get strings, you get objects, full of information and potentially also more objects. This is no different with dbatools, let's

$testPub = Get-DbaReplPublication -SqlInstance sql1 -Name testPub
$testPub | Get-Member
$testPub | Format-List *

// get articles from pub
