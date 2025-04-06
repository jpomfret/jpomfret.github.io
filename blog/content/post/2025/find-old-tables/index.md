---
title: "Find _old Tables"
slug: "find-old-tables"
description: "Have you ever had to do a little switch-a-roo on a table? Renamed the current one to append _old, so you can create a new one in it's place? Have you ever forgotten to go back and clear those up? Well, if so, this short blog is for you!"
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


```PowerShell
Get-DbaDbTable -SqlInstance mssql1 | Where-Object name -like '*_old'
```

![List of tables that match the filter with default properties returned](GetDbaDbTable.png)

There is more though

```PowerShell
Get-DbaDbTable -SqlInstance mssql1 |
Where-Object name -like '*_old' |
Select-Object SqlInstance, Database, Schema, Name, CreateDate, RowCount
```

![Table format showing selected properties of filtered tables](MoreProps.png)