---
title: "Find Databases where the T-Log is bigger than the data"
slug: "find-tlog-bigger-data"
description: "A quick blog to share a useful query to find databases where the transaction log is bigger than the total data file sizes."
date: 2024-01-23T11:23:51Z
categories:
    - T-SQL
    - UsefulQueries
tags:
    - T-SQL
    - UsefulQueries
image: joel-jasmin-forestbird-Kfy_FwhfPlc-unsplash.jpg
draft: true
---

This week I needed a query to find any databases where the transaction log is bigger than the total size of the data files. This is a red flag, and can happen for a few reasons that would need further investigation. However, this post is just to share the query, partly for you, and partly for future Jess.

If you do want to read more about why this could happen and how to fix it, Brent has a good post and some queries here: [Brent Ozar - Transaction Log Larger than Data File](https://www.brentozar.com/blitz/transaction-log-larger-than-data-file/).

I built this query by smooshing together some other useful queries from a few sources including [Stack Overflow](https://stackoverflow.com/) answers. Even in the co-pilot era I still do enjoy this website!

If you run the query as it is below you'll get a list of all the databases on your instance with columns for total log size in MB, total data size in MB and the total size of both combined in MB. There are some commented lines you can use, these will allow you to filter just for certain databases, or only show the results where databases have more log than data.

You'll also notice I used a [cte](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16) so I could reference the calculated columns by name, otherwise if I did this in the main query I would need to copy the logic into the where clause because of the order in which SQL Server executes the query (it doesn't know the names of the columns when it's working on the WHERE clause!).

```SQL
WITH cte AS (
SELECT
    d.name AS DatabaseName,
    CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(10,2)) AS log_size_mb,
    CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(10,2)) AS data_size_mb,
    CAST(SUM(size) * 8. / 1024 AS DECIMAL(10,2)) as total_size_mb
FROM sys.master_files mf
INNER JOIN sys.databases d
    on mf.database_id = d.database_id
--WHERE d.name IN ('master','dbadmin')
--WHERE d.database_id = DB_ID()
GROUP BY d.name
)
SELECT *
FROM cte
--WHERE log_size_mb > data_size_mb
ORDER BY total_size_mb DESC
```

The following image shows the results when run on my local environment, a docker container with a few small databases.

{{<
  figure src="results.png"
         alt="results from my local environment, a docker container"
>}}

Hope you find this post useful!

---

Header image by [Joel & Jasmin Førestbird](https://unsplash.com/@theforestbirds?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash) on [Unsplash](https://unsplash.com/photos/brown-tree-log-Kfy_FwhfPlc?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash)
