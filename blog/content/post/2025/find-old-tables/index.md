---
title: "Find _old Tables"
slug: "find-old-tables"
description: "Have you ever had to do a little switch-a-roo on a table? Renaming the current one to append _old, so you can create a new one in it's place? Have you ever forgotten to go back and clear those up? Well, if so, this short blog is for you!"
date: 2025-04-01T12:46:09Z
categories:
    - dbatools
    - powershell
tags:
    - dbatools
    - powershell
image:
draft: true
---

There are many reasons why you might end up with tables named `something_old` in your database. Perhaps this is part of your decommission strategy, to rename them to make sure they really aren't in use. Or, it could be because you need to make schema changes, you can rename the current table and create a new table with the desired schema.  But, the key to this blog post is when you then forget to come back and clean these tables up. We can easily find them with a [dbatools](https://dbatools.io/) command.

We can use `Get-DbaDbTable` to get all the tables from all databases on the specified instance, or instances. In the example below I have found all tables that end in `_old` in all databases on the `mssql1` SQL Server.

```PowerShell
Get-DbaDbTable -SqlInstance mssql1 | Where-Object name -like '*_old'
```

{{<
    figure src="GetDbaDbTable.png"
    alt="List of tables that match the filter with default properties returned"
>}}

There is more though, PowerShell deals in objects, and dbatools commands will return the properties we expect you to want to see, but there is often more available.

You can view all available properties by using `Get-Member`, this will show you the type of object returned, in this command it is a `Microsoft.SqlServer.Management.Smo.Table`, all the properties, and also methods that you can call on the object returned.

```PowerShell
Get-DbaDbTable -SqlInstance mssql1 | Get-Member
```

So from running the code above we know that there are additional properties available that would be interesting in this situation. Let's add `CreateDate` and `RowCount` in our `Select-Object` columns.

```PowerShell
Get-DbaDbTable -SqlInstance mssql1 |
Where-Object name -like '*_old' |
Select-Object SqlInstance, Database, Schema, Name, CreateDate, DateLastModified, RowCount
```

Now we have a good view into the tables that are named `_old`, when they were created, when they were last updated and the row count. This information should give you everything you need to be able to decide whether they can now be cleaned up.

#TODO: Update this screenshot to add last update date
{{<
    figure src="MoreProps.png"
    alt="Table format showing selected properties of filtered tables"
>}}

If after the analysis you decide they can all be removed, you can simply pipe the results to `Remove-DbaDbTable` to clean them up and reclaim some space.

```PowerShell
Get-DbaDbTable -SqlInstance mssql1 |
Where-Object name -like '*_old' |
Remove-DbaDbTable
```

That's it! Just a quick one today, but go and have a look around your environment and see if there are `_old` tables that could be cleaned up.