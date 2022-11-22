---
title: "Get a list of databases from named SQL Instances"
date: "2020-08-18"
categories:
  - "dbatools"
  - "powershell"
tags:
  - "dbatools"
  - "named-instance"
  - "powershell"
image: "taylor-vick-M5tzZtFCOfs-unsplash.jpg"
---

Have you ever had someone send you the name of a SQL Server and database to do some work, but when you try to connect to the server you can’t? Then,come to find out, there are four named instances on the box and you don’t know which one hosts the database? No? Just me?

Luckily, dbatools has a couple of commands that can help us out with this. Firstly, we can use `Get-DbaService` to get a list of instances that are running on the server:

$SqlInstances = Get-DbaService -ComputerName mssql1 -Type Engine |
Select @{L='SqlInstance';e={('{0}\\{1}' -f $\_.ComputerName, $\_.InstanceName)}}

I went ahead and piped this to the Select-Object and built the SqlInstance property to be ‘ServerName\\InstanceName’.  We can now use this in any of the other dbatools commands. For my use case I wanted database information, so I went with `Get-DbaDatabase`:

Get-DbaDatabase -SqlInstance $SqlInstances.SqlInstance |
Format-Table SqlInstance, Name, Status, RecoveryModel -AutoSize

This made it easy for me to find the database in question without having to connect to each instance manually.

You could also use this if you had a list of servers by just passing in a comma seperated list to the `-ComputerName` parameter on `Get-DbaService`.

Just a short post today, but hopefully useful to somebody.
