---
title: "dbatools Replication - Setup Replication"
slug: "dbatools-repl-setup"
description: "Lets take a look at how I can use dbatools to setup a transactional replication publication, add articles and create subscriptions."
date: 2024-03-09T08:00:00Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image: gabor-szucs-b4b-5FodP3I-unsplash.jpg
draft: true
---

Welcome to another post in my [dbatools](https://dbatools.io) replication series, where I'm working on showing off how dbatools can make managing replication easier. If you haven't seen the first two posts you can review them at the links below:

- [dbatools - introducing replication support](/dbatools-replication)
- [dbatools Replication: The Get commands](/dbatools-repl-get)

---

This post is focusing on how to setup replication with dbatools. We support all three flavours of replication - [snapshot](https://learn.microsoft.com/sql/relational-databases/replication/snapshot-replication?view=sql-server-ver16&WT.mc_id=AZ-MVP-5003655), [transactional](https://learn.microsoft.com/en-us/sql/relational-databases/replication/transactional/transactional-replication?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) and even [merge replication](https://learn.microsoft.com/sql/relational-databases/replication/merge/merge-replication?view=sql-server-ver16&WT.mc_id=AZ-MVP-5003655)! 

In this article I'll be creating a transactional publication, but the steps for setup are very similar no matter which flavour you're implementing.

I'll walk through and demonstrate all the steps to setup replication in this article as dbatools allows us to complete them all. However, I won't go into a lot of details on why or how replication works, or provide guidance on best practices. If you need more information on replication as a technology then I recommend visiting the [Microsoft Docs](https://learn.microsoft.com/en-us/sql/relational-databases/replication/sql-server-replication?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655).

## Setup Distributor and Publisher

Alright, step 1! 

Replication requires a server that is configured as a distributor, and a server that is configured as a publisher. 

Good news, these pieces of the puzzle can both be configured on the same server which is what I'll demonstrate in my test environment. In environments where replication has a high throughput and\or requires peak performance you can configure a separate server for distribution to move some of the load off of the publisher.

### Setup Distributor

First, I will use `Enable-DbaReplDistributor` to configure my `sql1` instance as the distributor, this is completed with the following code:

```PowerShell
Enable-DbaReplDistributor -SqlInstance sql1
```

You can see the following output is returned, note that the `DistributionDatabase` property is null, this is what is returned from the [RMO](https://learn.microsoft.com/en-us/sql/relational-databases/replication/concepts/replication-management-objects-concepts?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655) command dbatools uses under-the-hood.

There is an optional parameter `-DistributionDatabase` if you want to specify a certain name for the database that is created on the distributor, but if you don't specify, the database will be called `distribution` which is the default. Same as if you were to create it through SSMS.

```
ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : True
IsPublisher          : False
DistributionServer   : SQL1
DistributionDatabase :
```

You can see in the results above that `IsDistributor` returns true now and if I connect to `sql1` in SSMS I can now see the `distribution` database exists under the system databases. We are ready to move onto creating our publisher.

{{<
  figure src="distributiondb.png"
         alt="SSMS connected to sql1 instance, showing that there is a distribution database now,"
>}}

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

> Throughout this series of blog posts I'm demonstrating the simplest set of parameters for the commands, but there is more available. As you work through setting up replication in your environment, I'd recommend reading the dbatools docs or running `Get-Help <<command>> -Full` in your PowerShell session to see all the available parameters and examples on how to use them.

For the two commands we've just used you can see the dbatools help documentation here:

- [Enable-DbaReplDistributor](https://dbatools.io/Enable-DbaReplDistributor)
- [Enable-DbaReplPublishing](https://dbatools.io/Enable-DbaReplPublishing)

## Create Publications

As I mentioned the steps are very similar for whatever flavour of replication you want to create, in this post I'll create a transactional replication publication - this is (in my opinion) the most common type that is used in the real world. Transactional replication allows us to replicate changes from one database to another for certain objects in near real time.

The really cool thing here is that this is object level, unlike other technologies like Availability Groups, we can replicate just one table, or even just certain rows from one table based on a filter.

Ok, I'll use `New-DbaReplPublication` to specify the basic parameters needed to create a publication. In the code snippet below you can see this publication will be created on the `sql1` instance, for the `AdventureWorksLT2022` database, it'll be named `testPub` and it'll be of type `transactional` as I mentioned before.

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

Once this is executed the following output will be returned, showing a publication has been created. You can see that currently it contains no articles, and there are no subscriptions - makes sense, since we've only just created the publication.

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

More information on this command is available in the dbatools help documentation here:

- [New-DbaReplPublication](https://dbatools.io/New-DbaReplPublication)

## Add an Article

Once we have a publication in place it's time to add articles, these are the objects we want to replicate from one database to another. I'm going to use `Add-DbaReplArticle` to add the `SalesLT.Customer` tables to my `testpub` publication.

You'll also notice in this case I've added a `Filter` this is a `WHERE` clause that will filter the rows that are replicated. I think this is a really cool feature, for this setup only rows where `lastname = 'gates'` will be replicated to the subscriber.

```PowerShell
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'SalesLT'
    Name        = 'Customer'
    Filter      = "lastname = 'gates'"
}
Add-DbaReplArticle @article
```

Executing that returns the following output showing that my article has been added successfully.

```text
ComputerName      : sql1
InstanceName      : MSSQLSERVER
SqlInstance       : [sql1]
DatabaseName      : AdventureWorksLT2022
PublicationName   : testPub
Name              : Customer
Type              : LogBased
VerticalPartition : False
SourceObjectOwner : SalesLT
SourceObjectName  : Customer
```

If I review the properties of the publication from SSMS I can see that the article has been added successfully.

{{<
    figure src="article.png"
    alt="Properties pane for the testPub publication showing articles"
>}}

If I change to look at the `Filter Rows` page I can see the filter I specified is in place.

{{<
   figure src="articlefilter.png"
   alt="Filter Rows page of the testPub publication properties window"
>}}

More information on this command is available in the dbatools help documentation here:

- [Add-DbaReplArticle](https://dbatools.io/Add-DbaReplArticle)

Alright, the final piece of this puzzle is to add a subscription.

## Add a Subscription

Now that I've created a publication and added an article, I need to configure where this should be replicated too, which is the subscriber. In my demo environment I'm going to replicate to the `sql2` instance, but you could replicate to another database on the same `sql1` instance.

I'll run `New-DbaReplSubscription` to create this final piece, and below in the PowerShell code you can see I'm specifying the `testPub` publication we created on the `sql1` instance, and then a database of the same name `AdventureWorksLT2022` on the `sql2` instance.

If the database doesn't exist on the subscriber server then dbatools will create it with the defaults. In your production environments you'll probably want to create the database ahead of time and ensure it is set up to meet your best practices.

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

This command doesn't return anything at the moment but since no errors are returned we will assume all worked as expected. I could run `Get-DbaReplSubscription -SqlInstance sql1` to confirm this.

I can also view the publication in SSMS and see that there is a subscription to it.

{{<
   figure src="pubwithsub.png"
   alt="SSMS showing publication with a subscription to it"
>}}

Once again, I recommend viewing the help for the command we've used in this section for more information:

- [New-DbaReplSubscription](https://dbatools.io/New-DbaReplSubscription)

## Run the Snapshot Agent

Replication relies on executables that live outside of the SQL Server Engine, but are controlled by SQL Server Agent jobs. To start the data flowing for our new publication we need to first run the snapshot agent. We can use dbatools to find the job. In my demo environment, I know there is only one snapshot job, so I can make use of the `-Category` parameter to find the `repl-snapshot` jobs. Then I pipe the output to `Start-DbaAgentJob` and the snapshot agent will be started.

```PowerShell
Get-DbaAgentJob -SqlInstance sql1 -Category repl-snapshot | 
Start-DbaAgentJob
```
The output of this command shows it found the `SQL1-AdventureWorksLT2022-testPub-1` job and started it.

```text
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

If I look at replication monitor now I can see that the snapshot is complete and replication is all green and working.

{{<
   figure src="replMonitor.png"
   alt="Replication monitor showing everything is green"
>}}

Now these commands aren't specifically related to replication, but all dbatools commands have this fantastic online help, so feel free to check that out on the website:

- [Get-DbaAgentJob](https://dbatools.io/Get-DbaAgentJob)
- [Start-DbaAgentJob](https://dbatools.io/Start-DbaAgentJob)


## Testing time

With transactional replication, the magic is that rows are replicated (in near real time) as they change on the publisher. Let's prove the replication we've configured is working as expected by inserting a row into the `SalesLT.Customer` table on the `sql1` instance.

First step, let's review the data we have on the publisher, `sql1`, remember that I added a horizontal filter to the article so I only really care about the data in this table that matches the filter. I'll run the following T-SQL to see what we have to start with.

```sql
USE AdventureWorksLT2022 
GO

SELECT *
FROM SalesLT.Customer
WHERE lastname = 'gates'
```

The results show we have two rows that match the filter, both for Janet Gates.

{{<
   figure src="BeforeInsertingaRow.png"
   alt="SSMS showing the select statement results, two rows both for Janet Gates"
>}}

Let's insert a new row with the following T-SQL.

```sql
INSERT INTO SalesLT.Customer (NameStyle,Title,FirstName,LastName,PasswordHash,PasswordSalt,rowguid)
VALUES ('0','Mr.','Bill','Gates','ElzTpSNbUW1Ut+L5cWlfR7MF6nBZia8WpmGaQPjLOJA=','nm7D5e4=','949E9AC8-F8F6-4F7F-8888-87187AC56919')
```

You can see the results below, 1 row affected on the publisher.

{{<
   figure src="insert.png"
   alt="Results of the insert statement in SSMS - 1 row affected"
>}}

Rerunning the select on `sql1` would show we now have 3 rows that match the filter, but the real test is to see if the row has been replicated to the subscriber, `sql2`. Let's change the connection in SSMS to `sql2` and rerun the select statement.

{{<
   figure src="newRow.png"
   alt="SSMS connected to sql2 showing three rows returned by the select statement"
>}}

In the results above you can see the row has been replicated. Usually by the time I change connection and run the select the row is already there. As this is a test system with no load this isn't surprising, you might see some latency in a higher throughput environment.

I can also review the replication monitor and check out the messages for the `Log Reader Agent`, below you can see 1 transaction with 1 command was delivered.

{{<
   figure src="rowIsReplicated.png"
   alt="Replication Monitor showing `1 transaction(s) with 1 command(s) were delivered`"
>}}

That's the end of my post today, I now have a working transactional publication setup and I'm replicating data from `sql1` to `sql2`.

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
  figure src="/sqlbits.png"
         alt="I'm Speaking at SQLBits"
         link="https://sqlbits.com/attend/the-agenda/friday/#Managing_replication_with_dbatools"
>}}

Header Photo by [Gabor Szucs](https://unsplash.com/@gabcsika?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash) on [Unsplash](https://unsplash.com/photos/body-of-water-surrounded-with-trees-under-white-skies-b4b-5FodP3I?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash)
  