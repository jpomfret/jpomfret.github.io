---
title: "T-SQL Tuesday #108 - Non SQL Server Technologies"
date: "2018-11-13"
categories: 
  - "dsc"
  - "powershell"
  - "t-sql-tuesday"
tags: 
  - "dsc"
  - "powershell"
  - "sql-server"
  - "tsql2sday"
---

[![](images/tsqltues.png)](https://curiousaboutdata.com/2018/10/29/t-sql-tuesday-108-invitation-non-sql-server-technologies/)It’s T-SQL Tuesday time again, I have struggled in the last month or two to get anything up on my blog. Turns out weddings are pretty time consuming ?! Now that I’m happily married and home from an amazing [honeymoon in Hawaii](https://www.instagram.com/jpomfret/) it’s back to work on my blog and professional development.  Which makes this T-SQL Tuesday topic a perfect one to get back to, so thanks to Malathi Mahadeven ([B](https://curiousaboutdata.com)|[T](https://twitter.com/sqlmal)) for hosting this month.

I feel like with last week’s PASS Summit (I didn’t attend this year so just watching from afar) it makes it even harder than usual to pick just one thing to learn.  There are so many things right now that I want to read about or fiddle with.

I’ve decided to pick a main subject, with an auxiliary bonus area attached - kind of cheating, I know.  I’ve been working on a project at work to automate our SQL Server builds with Powershell Desired State Configuration (DSC) so this will be my main goal. I already have a basic understanding of how DSC works and how to install SQL Server with it, I want to improve this knowledge to the point where I can present a session on it.

The side goal is docker/containers/kubernetes (maybe), I’m wondering if I could use these to test my DSC configurations, maybe not to install SQL Server (I have no idea though) but I imagine I could configure SQL Server running in a container.

I saw the tweet below last week from the beard, [Rob Sewell](https://twitter.com/sqldbawithbeard), that quoted [Bob Ward’s](https://twitter.com/bobwardms) thoughts on learning directions.  Feels like this is probably solid advice to justify my side goal.

https://twitter.com/sqldbawithbeard/status/1061032613979267072

## Learning Plan

#### Learn DSC Basics – completed

I’ve already started learning DSC, I was lucky enough to take a PowerShell DSC class a couple of months ago and that combined with reading online documentation and blogs has given me a good base.

Resources:

- Microsoft Docs - [https://docs.microsoft.com/en-us/powershell/dsc/overview](https://docs.microsoft.com/en-us/powershell/dsc/overview)
- SQLServerDSC Github - [https://github.com/PowerShell/SqlServerDsc](https://github.com/PowerShell/SqlServerDsc)
- DSC Install of SQL Server [https://chrislumnah.com/2017/03/07/dsc-install-of-sql-server/](https://chrislumnah.com/2017/03/07/dsc-install-of-sql-server/)
- Making modules available in Push mode [http://nanalakshmanan.com/blog/Push-Config-Pull-Module/](http://nanalakshmanan.com/blog/Push-Config-Pull-Module/)

#### Learn more about how DSC resources are written and developed

This is where I currently am, I have the basics up and running to install SQL Server (blog post coming one day) but there are things I’d like to configure that aren’t currently built into the SQLServerDSC module.  Since this is open sourced on github I have the opportunity to learn while doing, I’ve already started working on adding an SQL Agent Operator resource so I can configure an operator during my install.

#### DSC, SQL Server and Containers?

Can I even use DSC to configure SQL Server running in a container? I have no idea, but I plan on finding out.  If this is possible it feels like this would be a really easy way to spin up ‘unconfigured’ SQL Server and test my configurations.  If not – hey maybe I learned a bit about containers along the way, and it feels like those are only getting more mainstream.

#### Final goal - Present a DSC session

My final goal is to create a 'Automate your SQL Server Install with DSC' session. Presenting on something forces you to learn it in depth, this will be great for myself and hopefully the community. Hopefully it'll make its way to a SQL Saturday next year.  The session would be a crash course on DSC specifically to install and configure SQL Server with the end goal of attendees being able to use this process to automate their own builds. Watch this space, currently in the idea phase.
