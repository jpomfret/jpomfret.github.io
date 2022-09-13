---
title: "Using T-SQL to Aggregate Strings"
date: "2020-06-23"
categories: 
  - "t-sql"
tags: 
  - "aggregates"
  - "tsql"
coverImage: "martin-sanchez-MD6E2Sv__iA-unsplash.jpg"
---

I’m a SQL Server Database Engineer by day, but I must say my blog has a lot more PowerShell and automation posts than T-SQL.  However, last week I found a really great T-SQL aggregate function that I had no idea existed, so I thought I’d share it with you.

I have been working on a project to document our SQL Server environment and create GitHub issues for things that need fixed. Issues are written in markdown so you can easily generate some pretty good looking issues with plenty of data using PowerShell. This is worth a blog post of it’s own, so keep an eye out for that soon.

Long story short I wanted a way to be able to list all the SQL Server instances on the server I was logging the issue for. I have a database with two tables, one that contains server information and one that contains instance information. Running the following gets me one row per server/instance combination.

SELECT s.ServerListId, s.ServerName, i.InstanceListId, i.InstanceName
FROM ServerList s
INNER JOIN InstanceList i
    ON s.ServerListId = i.ServerListId

| ServerListId | ServerName | InstanceListId | InstanceName |
| --- | --- | --- | --- |
| 1 | MSSQL1 | 1 | MSSQLSERVER |
| 2 | MSSQL2 | 2 | MSSQLSERVER |
| 3 | MSSQL3 | 3 | MSSQLSERVER |
| 2 | MSSQL2 | 4 | NAMEDINST1 |
| 2 | MSSQL2 | 5 | NAMEDINST2 |

I started thinking about how to group this data by server name and then concatenate the instance names together. Luckily a quick google found [STRING\_AGG()](https://docs.microsoft.com/en-us/sql/t-sql/functions/string-agg-transact-sql?view=sql-server-ver15). This T-SQL aggregate function has only been available since SQL Server 2017, and does exactly what I needed. It takes two parameters, the first being the column name that should be aggregated and the second a separator to use.

For this example I’ll group by ServerName, and aggregate the InstanceName column using a comma to separate the values.

SELECT ServerName, STRING\_AGG(InstanceName,', ') as InstanceName
FROM ServerList s
INNER JOIN InstanceList i
    ON s.ServerListId = i.ServerListId
GROUP BY ServerName

| ServerName | InstanceName |
| --- | --- |
| MSSQL1 | MSSQLSERVER |
| MSSQL2 | MSSQLSERVER, NAMEDINST1, NAMEDINST2 |
| MSSQL3 | MSSQLSERVER |

Hope some of you find this quick T-SQL post useful. It definitely fit my need well for this scenario.
