---
title: "Quickly Execute a Folder of SQL Scripts against a SQL Server"
description: "Using dbatools to quickly execute a folder of T-SQL scripts against your instance."
slug: "execute-folder-of-scripts"
date: "2021-03-01"
categories:
  - "dbatools"
  - "powershell"
tags:
  - "dbatools"
  - "powershell"
  - "sql-server"
image: "cover.jpg"
---

Another week and another useful dbatools snippet for you today.  Last week at work I was given a folder of 1,500 scripts – each containing a create table statement. Can you imagine having to open each file in Management Studio to be able to execute it? Thank goodness we have PowerShell and [dbatools](https://dbatools.io/) on our side.

The code for this example is pretty short, but there are a couple of things to point out.

First, I used `Connect-DbaInstance` to create a server object to use to run the queries.  This means that we’re efficiently reusing the connection rather than opening a new one for each file we want to execute.

Second, I’m using the foreach method which takes each script file returned from the `Get-ChildItem` call, and executes `Invoke-DbaQuery`.  With this we can use the `-File` parameter to pass in the sql file and that’s really all we need.  This will loop through each file running the sql scripts.

```PowerShell
$SqlInstance = 'mssql1'
$destinationDatabase = 'AdventureWorks2021'
$folderPath = '.\\output\\AdventureWorks2017'

# Create a connection to the server that we will reuse - can use SqlCredential for alternative creds
$sqlInst = Connect-DbaInstance -SqlInstance $SqlInstance

(Get-ChildItem $folderPath).Foreach{
    Invoke-DbaQuery -SqlInstance $sqlInst -Database $destinationDatabase -File $psitem.FullName
}
```

That’s really all we need for this blog post, but in order to set this up for a demo I did use a few other dbatools commands. I’ve posted the script above, along with the setup scripts on my [GitHub](https://github.com/jpomfret/demos/blob/master/BlogExamples/08_ExecuteFolderOfScripts.ps1). This includes creating a new database, scripting out all the tables into individual script files, and ensuring all the schemas and other dependencies were ready in the new database.

Thanks for reading, and hope this is a useful snippet. It sure saved me a lot of time this week.
