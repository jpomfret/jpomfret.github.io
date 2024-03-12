---
title: "dbatools replication - the Get- commands"
slug: "dbatools-repl-get"
description: "This post will show off all the Get- commands that are available within dbatools for replication."
date: 2024-02-28T10:00:00Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image: replmonitor.png
draft: false
---

Welcome to the second post in this series on [dbatools](https://dbatools.io/) replication support.

This post will show off all the `Get-` commands that are available within dbatools for replication. When you're using PowerShell, and especially if you're new to PowerShell, exploring the `Get-` commands for a certain module, or area is a great way to get started. As it says in the name, these commands get information about something, they aren't going to change anything, which means they are pretty safe to run in your environment. Of course, I'm always going to say, you should still run these in your test environment first to make sure you understand what they are doing, and how they behave in your specific environment.

As we were building in support for replications to dbatools, we started by building these `Get-` commands. This gave us a good way of exploring the [Replication Management Objects (RMO)](https://learn.microsoft.com/en-us/sql/relational-databases/replication/concepts/replication-management-objects-concepts?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) and understanding how they worked. We also wanted to make sure that we could get all the information we needed to be able to build the other commands that would be used to manage replication.

I'm going to split this post up into three sections - the first will look at the server level commands, the second will look at publications and subscriptions, and then, finally, we'll look more closely at articles. If you're not familiar with how replication works within SQL Server I'd recommend reviewing the [Microsoft docs](https://learn.microsoft.com/en-us/sql/relational-databases/replication/sql-server-replication?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) to familiarise yourself with the basic topologies and the terminology for the pieces and parts involved.

These posts are more about how to use dbatools to manage replication, rather than how replication works.

## Server level commands

In order for replication to be setup there needs to be a SQL instance that is a publisher and one that is a distributor. These can be the same SQL instance, or separate ones. I will show how to set these up with dbatools in the next post, but for now we can use the `Get-` commands to see what is already setup in our environment.

If we run the following we can get an overview of the target server, and see if it's setup as a distributor or a publisher, or perhaps both.

```PowerShell
Get-DbaReplServer -SqlInstance sql1
```

The results show us that `sql1` is configured as both a distributor and a publisher and that the distribution databases is called `distribution`. This is the default, but when configuring this with dbatools it is an option to rename it if you wish.

```text
ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : True
IsPublisher          : True
DistributionServer   : SQL1
DistributionDatabase : distribution
```

One of the great things about PowerShell is that the output returned from the commands are objects, not just strings. The results from the `Get-DbaReplServer` command, for example, are of type `Microsoft.SqlServer.Replication.ReplicationServer`. There are a lot more properties available on this command, but we try to return the most pertinent information by default.

If you want to explore all the properties you can either run `Get-DbaReplServer -SqlInstance sql1 | Format-List *`, which is basically like running a `SELECT *` statement in T-SQL. Or you can run `Get-DbaReplServer -SqlInstance sql1 | Get-Member` and you'll get a list of all the properties and methods available which can be really useful.

I mention this because the next command also returns the same type of object, we just choose, by default, different properties to return. `Get-DbaReplDistributor` is focused on things we care about when we're looking at a distributor - so you can see by running this command against our `sql1` instance we get different properties returned.

```PowerShell
Get-DbaReplDistributor -SqlInstance sql1
```

You can still see that `IsPublisher` and `IsDistributor` are returned, but now we also see properties like `HasRemotePublisher` and `DistributorAvailable`.

```text
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

The final command to mention in this section is `Get-DbaReplPublisher` and this actually returns a different object which contains all our publisher specific properties (`Microsoft.SqlServer.Replication.DistributionPublisher`).  If we run this against `sql1` you can still see some distribution information since these pieces are closely related, but now we see a status, working directory and the type of publisher.

```PowerShell
Get-DbaReplPublisher -SqlInstance sql1
```

```text
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

For more information and examples for each of these commands, check out the dbatools help documentation:

- [Get-DbaReplServer](https://dbatools.io/Get-DbaReplServer)
- [Get-DbaReplDistributor](https://dbatools.io/Get-DbaReplDistributor)
- [Get-DbaReplPublisher](https://dbatools.io/Get-DbaReplPublisher)

## Publications and Subscriptions

The next piece of this replication puzzle is our publications and subscriptions. Publications live on the publisher and contain articles which are the objects to replicate (think tables, views, stored procedures). We can view all the publications on our instance by running the following command.

```PowerShell
Get-DbaReplPublication -SqlInstance sql1
```

The output shows us we have three publications set up on `sql1`. If you review the type of each you'll see there is one transactional, one snapshot and one merge publication - these are the three types we have available to use. Again the output is an object, and if you look at the `Articles` and `Subscriptions` properties you can see that these are also objects, if you were to dig into those you could see all the article properties or all subscription properties. Really cool stuff if you ask me!

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

Again, you'll notice we're just returning some of the properties, that we think you're most likely going to want to know about - if you need more information it's likely there, just pipe to `Get-Member` or `Format-List *` to see all the available information.

The second `Get-` command we'll look at here is the `Get-DbaReplSubscription` command, and you should be able to guess by now what that might return.

One thing to note on this command is the target `SqlInstance` we'll use to pass into the command. In my mind, subscriptions are on the destination server in replication but SQL server stores the information on the publisher side, so although in my current setup I'm replicating from `sql1` to `sql2` I will still use `sql1` as the `SqlInstance` parameter.

```PowerShell
Get-DbaReplSubscription -SqlInstance sql1
```

The results of this command confirm what I was just explaining, we have three subscriptions, one for each of our publications. You can see that each publication is replicating to the same destination instance, `sql2`, but each has a different target database.

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

Finally lets take a look at `Get-DbaReplArticle` this will return information about our articles. We can again run it with just the `-SqlInstance` parameter, this will then return all the articles within publications on that target instance.

```PowerShell
Get-DbaReplArticle -SqlInstance sql1
```

If we run it against `sql1` you can see that within my test environment I have three articles, one in each publication.

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

Now as you already know from the previous discussion about output in this post, the output returned is objects not just text. In this case, one of these articles has a secret.

Let's use another parameter available on `Get-DbaReplArticle` to filter by the `Name` of the article, and then pipe that output to `Select-Object` where we can select the properties we are interested in. Here you'll see I've added a property called `FilterClause` which shows if the article is making use of horizontal filtering.

```PowerShell
Get-DbaReplArticle -SqlInstance sql1 -Name customer |
Select-Object SqlInstance, DatabaseName, PublicationName, Name, SourceObjectOwner, SourceObjectName, FilterClause
```

In the results you can see that this article only replicates rows that match the where clause of `lastname = 'gates'` which is a pretty cool feature of replication.

```text
SqlInstance       : [sql2]
DatabaseName      : AdventureWorksLT2022
PublicationName   : testPub
Name              : customer
SourceObjectOwner : SalesLT
SourceObjectName  : Customer
FilterClause      : lastname = 'gates'
```

For more information and examples for each of these commands, check out the dbatools help documentation:

- [Get-DbaReplArticle](https://dbatools.io/Get-DbaReplArticle)
- [Get-DbaReplArticleColumn](https://dbatools.io/Get-DbaReplArticleColumn)

## Bonus

The examples I've shown here are the most basic ways to use each of the commands, many have additional parameters to allow you to filter the results by database, or publication name for example. I highly recommend checking out the online docs for dbatools - or running `Get-Help` as shown below. All the commands have the parameters fully explained, and examples of how to use them.

```PowerShell
Get-Help Get-DbaReplArticle -ShowWindow
```

## Series

This is part of a series of posts covering how to use the dbatools replication commands, other posts in the series:

- [dbatools - introducing replication support](/dbatools-replication)
- dbatools Replication: The Get commands - this post!
- [dbatools Replication: Setup replication with dbatools](/dbatools-repl-setup)
- dbatools Replication: Tear down replication with dbatools

You can also view any posts I've written on Replication by heading to the [Replication Category](/categories/replication/) page of this blog.

## Presentation at SQLBits

Also don't forget I'm presenting 'managing replication with dbatools' at SQLBits 2024 in just a few weeks!

{{<
  figure src="/sqlbits.png"
         alt="I'm Speaking at SQLBits"
         link="https://sqlbits.com/attend/the-agenda/friday/#Managing_replication_with_dbatools"
>}}
