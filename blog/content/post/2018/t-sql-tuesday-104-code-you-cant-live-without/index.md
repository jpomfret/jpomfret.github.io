---
title: "T-SQL Tuesday #104 – Code you can't live without"
slug: "t-sql-tuesday-104"
description: "Take a look at my favourite code snippet in this edition of the monthly blog party."
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

{{<
  figure src="/tsqltues-300x300.png"
         link="https://bertwagner.com/2018/07/03/code-youd-hate-to-live-without-t-sql-tuesday-104-invitation/"
         class="float-left"
         alt="T-SQL Tuesday Logo"
         width="300px"
         height="300px"
>}}

As soon as I saw Bert Wagner ([t](https://twitter.com/bertwagner)|[b](https://bertwagner.com/)) post his T-SQL Tuesday topic last week I knew this was going to be a great one. I’m really looking forward to reading about everyone’s favourite code snippets so thanks Bert for hosting and choosing a fantastic subject!

A lot of the code I can't live without is either downloaded from the community (e.g. [sp_whoisactive](http://whoisactive.com/), [sp_indexinfo](http://karaszi.com/spindexinfo-enhanced-index-information-procedure), [sp_blitz](https://www.brentozar.com/blitz/)), or very specific to my workplace so I'm going to share some code that I've been meaning to blog about.

I’ve been using this at work recently and it also relates to the presentation I gave at the [ONSSUG June meeting](http://jesspomfret.com/first-user-group-presentation-i-survived/) around data compression. The beginnings of this script originated online as I dug into learning about the DMVs that related to objects and compression and then customized for what I needed.

If you run the below as is it will provide basic information about all objects in your database, except those in the 'sys' schema, along with their current size and compression level.

```SQL
SELECT
    schema_name(obj.SCHEMA_ID) as SchemaName,
    obj.name as TableName,
    ind.name as IndexName,
    ind.type_desc as IndexType,
    pas.row_count as NumberOfRows,
    pas.used_page_count as UsedPageCount,
    (pas.used_page_count \* 8)/1024 as SizeUsedMB,
    par.data_compression_desc as DataCompression
FROM sys.objects obj
INNER JOIN sys.indexes ind
    ON obj.object_id = ind.object_id
INNER JOIN sys.partitions par
    ON par.index_id = ind.index_id
    AND par.object_id = obj.object_id
INNER JOIN sys.dm_db_partition_stats pas
    ON pas.partition_id = par.partition_id
WHERE obj.schema_id <> 4  -- exclude objects in 'sys' schema
    --AND schema_name(obj.schema_id) = 'schemaName'
    --AND obj.name = 'tableName'
ORDER BY SizeUsedMB desc
```

(This is also available in my [GitHub Tips and Scripts Repo](https://github.com/jpomfret/ScriptsAndTips/blob/master/ObjectSizeAndCompression.sql))

Now this T-SQL is great for a quick look at one database, but what if I want to run this script against every database in my environment? Well I popped over to PowerShell, fired up [dbatools](http://dbatools.io/) and ran the following:

```PowerShell
get-command -Module dbatools -Name *compression\*
```

Bad news, there was no Get-DbaDbCompression, there were commands for compressing objects (Set-DbaDbCompression) and for getting suggested compression setting based on the [Tiger Teams best practices](https://blogs.msdn.microsoft.com/blogdoezequiel/2011/01/03/the-sql-swiss-army-knife-6-evaluating-compression-gains/) (Test-DbaDbCompression), but nothing to just return the current compression status of the objects.

What’s more exciting than just using the greatest PowerShell module ever created? Making it better by contributing! So I made sure I had the latest development branch synced up and got to work writing Get-DbaDbCompression.  This has now been merged into the main branch and is therefore available in the Powershell gallery, so if your dbatools module is up to date you can now run the following to get the same information as above from one database:

```PowerShell
Get-DbaDbCompression -SqlInstance serverName -Database databaseName
```

Or go crazy and run it against a bunch of servers.

```PowerShell
$servers = Get-DbaRegisteredServer -SqlInstance cmsServer | Select-Object -expand ServerName
$compression = Get-DbaDbCompression -SqlInstance $servers
$compression | Out-GridView
```

I hope this post might come in handy for anyone who is curious about data compression in their environments. Both the T-SQL and PowerShell versions provide not just the current compression setting but the size of the object too. Useful if you are about to apply compression and would like a before and after comparison to see how much space you saved.
