---
title: "Collating index usage stats across Availability Group replicas"
date: "2021-11-16"
categories: 
  - "availability-groups"
  - "dbatools"
  - "powershell"
tags: 
  - "availability-groups"
  - "dbatools"
  - "powershell"
coverImage: "maksym-kaharlytskyi-Q9y3LRuuxmg-unsplash.jpg"
---

One of the benefits available to us when using SQL Server Availability Groups is that we can offload read activity to a secondary replica. This can be useful if we need to run reports against our OLTP databases. Instead of this taking up valuable resources on the primary instance we can make use of the otherwise idle secondary replica.

Note: This could affect your licensing standpoint, so ensure you’re in compliance on that front.

Last week, I was working on a project to analyse indexes on a database that was part of an availability group. The main goal was to find unused indexes that could be removed, but I was also interested in gaining an overall understanding of how the system was indexed.

Unused indexes not only take up disk space, but they also add overhead to write operations and require maintenance which can add additional load on your system.  We can also use this analysis to look for a high number of lookups which could indicate we need to adjust indexes slightly.

**_Note_**: dbatools does have a command called `Find-DbaDbUnusedIndex` to just look for unused indexes – however since I wanted to collect overall usage as well it wasn’t appropriate in this situation.

dbatools has a command `Get-DbaHelpIndex` which returns detailed information on our indexes which we can then use to complete the necessary analysis. To run this against a single database we could use the following code:

Get-DbaHelpIndex -SqlInstsance mssql1 -Database AdventureWorks | Out-GridView

In the above example I’ve used `Out-GridView` to popup the results in a nice, easy to view GUI. I love using this output option to get a feel for the results. You can also filter and sort to help do some initial analysis to help get an understanding of your data.

This is perfect – except I mentioned this database was in an AG. Oh, and it is set up to take advantage of using that read-only replica to run reporting against. That means the whole picture of the index usage is spread across two instances. We might find a totally unused index on our primary replica, a great candidate to be dropped, unless it’s heavily used by reports on the secondary.

Remember, the secondary replica is just a read-only copy – so the indexes needed on the secondary must be created on the primary.

In this situation we need to combine the index stats for both replicas into one easy to use result set – for this we can make use of PowerShell’s PSCustomObject to join these two result sets. In the code below I’ve set up a few variables at the top, and then run `Get-DbaHelpIndex` against both instances. We then set up a variable to catch the results in `$export` and use foreach-object to loop through the results for the primary instance. As we loop through, we’re looking for the matching index on the secondary replica before adding properties from both sides to the PSCustomObject.

Finally, we lean on the ImportExcel module to export the results to an excel spreadsheet – if you haven’t checked this module out yet I highly recommend it.

https://gist.github.com/jpomfret/a9afa22c4d1129fecc4ea3e6cde1b51c

Looking at our results spreadsheet we can now easily review the index usage across both replicas and make sure that any indexes we identify as unused, truly are unused.
