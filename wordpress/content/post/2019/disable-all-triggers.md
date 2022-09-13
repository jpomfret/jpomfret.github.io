---
title: "Disable all Triggers on a Database"
date: "2019-08-19"
categories: 
  - "powershell"
  - "triggers"
tags: 
  - "dbatools"
  - "powershell"
  - "smo"
  - "triggers"
---

Sometimes it’s best not to ask why. However, if for some reason you have a number of triggers on tables within a database that you would like to temporarily disable, read on.

I came across a situation recently while automating a process to refresh test environments where this exact scenario came up.  As part of the process several scripts were run to obfuscate production data. While these ran all the UPDATE triggers were firing. Not only were the triggers adding a significant amount of time to the process, they were also updating dates and other values that we’d prefer kept their original values.

Now, as I mentioned this is not a discussion on whether this is a good database design or not, this is just how to solve this issue.

In the snippet below I use `Connect-DbaInstance` from [dbatools](http://dbatools.io) to create a `$svr` object. If you don’t have dbatools installed you could either [install dbatools](http://dbatools.io/install), or use `New-Object Microsoft.SqlServer.Management.Smo.Server`. The dbatools function is essentially a wrapper around this command that adds a lot of additional checks and options.

I have also defined an array `$triggers` to keep track of the triggers I disable. It’s likely that you’ll want to put the environment back to how it started, so this will make sure you don’t enable any triggers that started off disabled.

Then we get to the actual work. Using the `$svr` object we can loop through all the tables, and then all the triggers on those tables. If a certain trigger is enabled, it is added to the `$triggers` array and then disabled using `$tr.isenabled`.  As with most (all?) changes made through SMO you then need to call the alter method ,`$tr.alter()`, to actually make the change on the server.

$database = ‘AdventureWorks2017’
$svr = Connect-DbaInstance -SqlInstance server1
$foreach ($tbl in $svr.databases\[$database\].Tables)
{
    foreach ($tr in $($tbl.Triggers | Where-Object Isenabled)) {
        $triggers += $tr | Select-Object @{l='SchemaName';e={$tbl.Schema}}, @{l='TableName';e={$tbl.name}}, @{l='TriggerName';e={$\_.name}}
        $tr.isenabled = $FALSE
        $tr.alter()
    }
}

When you are ready to enable the triggers again you can use the following code. This loops through the triggers that we had previously disabled and added to our array and enables them.

foreach($tr in $triggers) {
    $trigger = $svr.Databases\[$database\].Tables\[$tr.TableName,$tr.SchemaName\].Triggers\[$tr.TriggerName\]
    $trigger.IsEnabled = $true
    $trigger.alter()
}
