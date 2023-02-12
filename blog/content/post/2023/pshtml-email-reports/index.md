---
title: "PSHTML Email Reports"
slug: "pshtml-email-reports"
description: "Using the PSHTML PowerShell module to send beautiful email reports, and of course dbatools to get the data from SQL Server"
date: 2023-02-03T09:16:38Z
categories:
tags:
image:
---

I've been meaning to write a blog about the [PSHTML](https://github.com/Stephanevg/PSHTML#summary) module for a long time as I've used it many times to make great-looking HTML email reports. This is a great little PowerShell module that creates a domain specific language (DSL) within PowerShell that allows you to easily craft HTML directly from your PowerShell scripts.

You can use this PowerShell module to create full web pages, but I've used it more often to format the body of HTML emails to create beautiful reports. Pairing this module up with [dbatools](https://dbatools.io/) you can retrieve data from a SQL Server database and then depending on the results; since we're in PowerShell we can use all the conditional statements needed to determine how to handle the results, we can send out concise useful email reports.

> If you just want the script and to skip the explanation, head to the bottom of this post where I've linked to the full gist.

## Step 1 - Set up the variables

I like to set my PowerShell scripts in a way that makes them easy to reuse. Some call it lazy, but I like to say I'm an efficient script writer - the more I parameterise my scripts the easy they are to reuse.

In this case, it's useful to pull out all the variables needed to send the email using `Send-MailMessage` - you can see below I've got the email addresses we want to send the email to, the address showing where the email came from, a subject - which includes today's date, and the SMTP server we'll use to send the mail.

```PowerShell
## Email details
$emailTo = 'me@jesspomfret.com','team@jesspomfret.com'
$emailFrom = 'reports@jesspomfret.com'
$emailSubject = ('Authors: {0}' -f (get-date -f yyyy-MM-dd))
$smtpServer = 'smtp.server.address'
```

## Step 2 - Get some data

The beauty of this script is that the data can come from anywhere, you could use the Active Directory PowerShell module to get information on groups or users, or perhaps find all accounts with expired passwords or currently locked out. You could use CIM or WMI to collect information from your servers, like patch levels or last boot times. In my case I'm going to use [dbatools](https://dbatools.io/) to query a SQL Server database to retrieve some data.

In this example, we'll query a table within the `pubs` database to get a list of author information. This is nice and simple, but with the `Invoke-DbaQuery` command you can also run a stored procedure, so your reports can pull complex datasets as well.

Again I've got a few variables

```PowerShell
$sqlInstance = 'mssql1'
$sqlCredential = Import-Clixml .\sqladmin.cred
$database = 'pubs '
$query = @"
SELECT TOP (10) [au_id]
      ,[au_lname]
      ,[au_fname]
      ,[phone]
      ,[address]
      ,[city]
      ,[state]
      ,[zip]
  FROM [dbo].[authors]
"@

$querySplat = @{
    SqlInstance     = $sqlInstance
    SqlCredential   = $sqlCredential
    Database        = $database
    Query           = $query
    EnableException = $true
}
$results = Invoke-DbaQuery @querySplat
```

## Full Script

{{< gist jpomfret 895ee1ec9363cf991b324a227701d2e1 >}}
