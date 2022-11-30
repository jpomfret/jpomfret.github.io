---
title: "Getting OS and SQL Version information with dbatools"
description: "One of my favourite posts - use dbatools and ImportExcel to get an overview of what versions you have in your estate."
slug: "getting-versions"
date: "2019-05-30"
categories:
  - "dbatools"
  - "powershell"
tags:
  - "dbatools"
  - "excel"
  - "powershell"
---

There have been a lot of blog posts and talk around upgrading your servers in the past. However, the chatter always seems to intensify when we start getting close to that dreaded ‘end of support’ date for your older Windows and SQL Server versions.  I hope this isn’t the first place you are discovering this, but July 9th 2019 marks the end of support for both SQL Server 2008 and 2008R2, closely followed on January 14th 2020 with the end of support for Windows Server 2008 and 2008R2.

With these dates on the horizon it’s a good time to look at our estate and make sure we have a good understanding of the versions we currently support. I’m going to show you how to do that easily with a couple of [dbatools](https://dbatools.io/) functions. Then, bonus content, I’ll show you how to present it for your managers with one of my other favourite PowerShell modules [ImportExcel](https://github.com/dfinke/ImportExcel).

First things first, I need an object that contains our servers.  At my work we use a central management server to keep track of servers, but you could just as easily pull server names in from a text file, or a database.

```PowerShell
$servers = Get-DbaCmsRegServer -SqlInstance CmsServerName
```

Let’s first look at what operating systems we are running. The dbatools function we need for this is `Get-DbaOperatingSystem`. I’ll use the name property of my `$servers` object to get the OS information for all my servers and save it to a variable.

```PowerShell
$os = Get-DbaOperatingSystem -ComputerName $servers.name
```

I chose to save the results to a variable for this since I’m going to examine the results using PowerShell and then also output them to Excel, saving me from having to gather the information from each server multiple times. If I only planned on looking at the results on screen I could instead have just piped the `Get-DbaOperationSystem` results straight into `Group-Object`.

Using `Group-Object` I can quickly see how many servers I have for each versions of windows, and how many I have going out of support in the near future.

```PowerShell
$os | Group-Object OSVersion |
Sort-Object Name |
Select-Object Name, Count, @{l='Servers';e={$\_.Group.ComputerName -Replace '.domain.name,''  -Join ','}}
```

I have used the -Replace option in my `Select-Object` to remove the domain name from the output and instead only return the server name.

![Using Group-Object to count number of OS Version installations](os-2.jpg)

We can do the same with `Get-DbaProductKey` to get the SQL version information.

```PowerShell
$sql = Get-DbaProductKey -ComputerName $servers.name
$sql | Group-Object Version |
Sort-Object Name  |
Select Name, Count, @{l='Servers';e={$\_.Group.SqlInstance -join ','}}
```

![Using Group-Object to count number of SQL Version installations](sql.jpg)

With just 5 lines of code we can review our entire estate and make sure we know what we have nearing the end of support. This is pretty useful information, and also a good thing to export into a pretty spreadsheet and share with your team or management. Enter [ImportExcel](https://github.com/dfinke/ImportExcel).

If you haven’t used this module before, prepare to have your mind blown. Doug Finke has crafted some PowerShell magic to enable you to both import from and export to Excel, using PowerShell, without needing Excel installed even.

The full code is below. We’ve already done the work of gathering our data so if you are following along skip the first 3 lines below.

I’ve separated out the properties I want to select and will therefore end up in my spreadsheet. I’ve also used [splatting](https://dbatools.io/splat/) to make the call to `Export-Excel` easier to read.

{{< gist jpomfret 3e3449146f0d72fba9654ac09472cc0f >}}

The important part of this script is the parameters used for the `Export-Excel` call so I’ll go through them here:

Parameter Name    | Value | Comments
---------------   |--|--|
Path              | $excelFile           | The path to export the resulting Excel file to.
WorksheetName     | ‘OSVersions’         | The name for the worksheet that will contain the data. If the excel file already exists but the worksheet name does not this will be added to that document.
AutoSize          | $True                | Adjusts the width of the columns in your worksheet to the right size for your data.
TableName         | ‘OSVersions’         | Makes your result set into a table within your worksheet and names it.
IncludePivotTable | $True                | Adds a second worksheet with a pivot table of your data.
PivotRows         | 'OSVersions'         | The property of your data that will provide the rows for your pivot table.
PivotData         | @{OSVersion='Count'} | Fields to use in the body of your pivot table (in this example we are doing a simple count of the data).
IncludePivotChart | $True                | Add the chart with our pivot table.
ChartType         | ‘ColumnClustered’    | Define the kind of chart you want to display.

![Our final output - a beautiful excel pivot chart](ExcelOutput.jpg)

There you have it, a simple script to get the current OS and SQL versions you are running with a good looking Excel sheet as the output. Hope you don’t find too many instances out there nearing the end of support.
