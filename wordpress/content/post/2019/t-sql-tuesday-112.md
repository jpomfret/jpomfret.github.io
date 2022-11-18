---
title: "T-SQL Tuesday #112 - Dipping into your Cookie Jar"
date: "2019-03-12"
categories:
  - "presenting"
  - "t-sql-tuesday"
tags:
  - "presenting"
  - "tsql2sday"
image: "abundance-bazaar-biscuits-375904-e1552343553342.jpg"
---

[![](images/tsqltues-300x300.png)](https://nocolumnname.blog/2019/03/05/t-sql-tuesday-112-dipping-into-your-cookie-jar/)

It’s T-SQL Tuesday time again and our host this week, Shane O'Neill ([b](https://nocolumnname.blog/)|[t](https://twitter.com/SOZDBA)), has challenged us to a humble brag. This really is a challenge for most of us as we do awesome things quietly, so thanks to Shane for forcing us to share some ‘cookies’.  This is also the second time in a couple of weeks that [David Goggins’ book](https://www.amazon.com/Cant-Hurt-Me-Master-Your-ebook/dp/B07H453KGH) has been mentioned, which means I need to move it up on my to-read list.

Imposter syndrome is something a lot of us struggle with. I am going to share a couple of things that I’m proud of and that I can look back on when things get tough.  As I’ve written before I’m working hard on stepping out of my comfort zone to prepare and deliver technical presentations. Recently I’ve been building a presentation that has caused me to wonder many times, what was I thinking.  Hopefully this recap will remind me that I can do it.

### Automating Nonproduction Refreshes

This first story is a technical one. I was working on a project a year or so ago that involved complicated changes to business processes and therefore it was decided that development and test environments needed to be as similar to production as possible.  This meant that I was inundated with requests to take backups of production and restore to many nonproduction environments.  This got old fast.

The process not only involved the backup/restore piece, the data in production was both sensitive and encrypted using TDE.  I started writing PowerShell scripts for each step in the process, restoring certificates and databases, unencrypting and then removing certificates and then masking the sensitive data (which involved calling a T-SQL stored procedure built by my colleague, [Andrew](https://twitter.com/awickham)).  This was fine to begin with, but as the production data grew the process took longer and longer, which meant that the nonproduction environment was unavailable for longer each time.

After awhile this process was no longer acceptable because the test environments were down for too long. I met with the team and we came up with a plan.  We ended up agreeing that we would create a process to create ‘restore points’.  These would basically be points in time from production, that were prepared for nonproduction use, off hours in a temporary environment.  I utilized a combination of [Urban Code Deploy](https://developer.ibm.com/urbancode/products/urbancode-deploy/) (UCD), a product we already had in house, and PowerShell scripts to give the developers the power to first create a restore point, and then to be able to refresh environments from these prepackaged backups.

The process in UCD to create a restore point took the scripts I had been using manually and packaged them up so the result was a folder of already unencrypted, masked databases that were safe to restore to any of the test environments.  Everyone was happy, I no longer had to do this mundane, boring request and the team could refresh whenever they needed to, only having to wait for the restore to finish.

There is still plenty of room for improvement in this process. Perhaps we could use some kind of database cloning technology to minimize space requirements and reduce the time to restore. Another option would be running the databases in containers. The developers could then just spin up an environment when they needed to test something. For now, though, the process is making everyone’s life easier, and that was a big win for both myself and the project team.

### Speaking in Front of People!

The second humble brag is that I’m speaking in front of people! A year ago I had just agreed to give my first user group presentation and I was terrified.  I had set a goal of giving back to the community by blogging/writing and speaking, but the speaking part was by far the most difficult for me to get my head around. 

Thinking back to college, I dreaded finding out that class projects included final presentations. This hasn’t changed, and now I was voluntarily going to present.  In the last year I’ve put together a pretty decent hour-long presentation on data compression that I’ve delivered not once, but four times.  Each time I’ve grown in confidence and felt more like I could be myself in front of a crowd.  One of my demos that I’m particularly proud of shows how data compression affects the data storage on the page.  I then [wrote about this demo](https://jesspomfret.com/data-compression-internals/) and it was picked up and featured in [Brent Ozar’s](https://www.brentozar.com) weekly links.

I’ve also had my second presentation topic selected for [DataGrillen](https://datagrillen.com) and [SQL Saturday Cincinnati](https://www.sqlsaturday.com/827/eventhome.aspx). I’m working hard to make sure I can deliver an informative and useful session on the possibilities of using PowerShell Desired State Configuration to install and configure SQL Server. During this process it has often felt like I’ve bitten off more than I can chew, both on my topic choice and the fact I submitted it to an international conference with a superstar line up of speakers.

But here’s to remember the wins, and knowing I’ve already overcome these same doubts and challenges to get my first presentation up and running. This will be a great post to come back to when I need to dip in the cookie jar.
