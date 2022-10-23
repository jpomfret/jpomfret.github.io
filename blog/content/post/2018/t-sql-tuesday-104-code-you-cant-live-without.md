---
title: "T-SQL Tuesday #104 – Code you can't live without"
date: "2018-07-10"
categories: 
  - "data-compression"
  - "dbatools"
  - "t-sql-tuesday"
tags: 
  - "data-compression"
  - "dbatools"
  - "powershell"
  - "t-sql-tuesday"
---

[![](images/tsqltues-300x300.png)](https://bertwagner.com/2018/07/03/code-youd-hate-to-live-without-t-sql-tuesday-104-invitation/)As soon as I saw Bert Wagner ([t](https://twitter.com/bertwagner)|[b](https://bertwagner.com/)) post his T-SQL Tuesday topic last week I knew this was going to be a great one. I’m really looking forward to reading about everyone’s favorite code snippets so thanks Bert for hosting and choosing a fantastic subject!

A lot of the code I can't live without is either downloaded from the community (e.g. [sp\_whoisactive](http://whoisactive.com/), [sp\_indexinfo](http://karaszi.com/spindexinfo-enhanced-index-information-procedure), [sp\_blitz](https://www.brentozar.com/blitz/)), or very specific to my workplace so I'm going to share some code that I've been meaning to blog about.

I’ve been using this at work recently and it also relates to the presentation I gave at the [ONSSUG June meeting](http://jesspomfret.com/first-user-group-presentation-i-survived/) around data compression. The beginnings of this script originated online as I dug into learning about the DMVs that related to objects and compression and then customized for what I needed.

If you run the below as is it will provide basic information about all objects in your database, except those in the 'sys' schema, along with their current size and compression level.

SELECT
	schema\_name(obj.SCHEMA\_ID) as SchemaName,
	obj.name as TableName,
	ind.name as IndexName,
	ind.type\_desc as IndexType,
	pas.row\_count as NumberOfRows,
	pas.used\_page\_count as UsedPageCount,
	(pas.used\_page\_count \* 8)/1024 as SizeUsedMB,
	par.data\_compression\_desc as DataCompression
FROM sys.objects obj
INNER JOIN sys.indexes ind
	ON obj.object\_id = ind.object\_id
INNER JOIN sys.partitions par
	ON par.index\_id = ind.index\_id
	AND par.object\_id = obj.object\_id
INNER JOIN sys.dm\_db\_partition\_stats pas
	ON pas.partition\_id = par.partition\_id
WHERE obj.schema\_id <> 4  -- exclude objects in 'sys' schema
	--AND schema\_name(obj.schema\_id) = 'schemaName'
	--AND obj.name = 'tableName'
ORDER BY SizeUsedMB desc

(This is also available in my [GitHub Tips and Scripts Repo](https://github.com/jpomfret/ScriptsAndTips/blob/master/ObjectSizeAndCompression.sql))

Now this T-SQL is great for a quick look at one database, but what if I want to run this script against every database in my environment? Well I popped over to PowerShell, fired up [dbatools](http://dbatools.io/) and ran the following:

get-command -Module dbatools -Name \*compression\*

Bad news, there was no Get-DbaDbCompression, there were commands for compressing objects (Set-DbaDbCompression) and for getting suggested compression setting based on the [Tiger Teams best practices](https://blogs.msdn.microsoft.com/blogdoezequiel/2011/01/03/the-sql-swiss-army-knife-6-evaluating-compression-gains/) (Test-DbaDbCompression), but nothing to just return the current compression status of the objects.

What’s more exciting than just using the greatest PowerShell module ever created? Making it better by contributing! So I made sure I had the latest development branch synced up and got to work writing Get-DbaDbCompression.  This has now been merged into the main branch and is therefore available in the Powershell gallery, so if your dbatools module is up to date you can now run the following to get the same information as above from one database:

Get-DbaDbCompression -SqlInstance serverName -Database databaseName

Or go crazy and run it against a bunch of servers.

$servers = Get-DbaRegisteredServer -SqlInstance cmsServer | select -expand servername
$compression = Get-DbaDbCompression -SqlInstance $servers
$compression | Out-GridView

I hope this post might come in handy for anyone who is curious about data compression in their environments. Both the T-SQL and PowerShell versions provide not just the current compression setting but the size of the object too. Useful if you are about to apply compression and would like a before and after comparison to see how much space you saved.
