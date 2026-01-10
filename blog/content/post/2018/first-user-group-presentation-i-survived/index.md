---
title: "First User Group Presentation - I Survived!"
description: "A recap of my first every presentation, and a shout out to the friends that helped me through it!"
slug: "first-user-group-presentation-i-survived"
date: "2018-06-27"
categories:
  - "presenting"
tags:
  - "data-compression"
  - "dbatools"
  - "presenting"
---

Well tonight marks three weeks since I gave my first user group presentation and you know what, it’s been a total whirlwind since then so I’ve had little time to reflect.  Myself and the fiancé closed on our first house and my parents flew in to visit. It’s very useful to have people on hand the first couple of weeks so we didn’t feel like completely unqualified homeowners. I spent some time right after the presentation to start breathing again and to jot down some thoughts, but this is the first chance I’ve had to report back.

TL;DR I didn’t die, the SQL Server community is fantastic and I have amazing supportive friends.

## Why Present?

The answer to this is twofold. Firstly this year I’ve challenged myself to get more involved in the SQL Server community. For several years now I’ve attended user group meetings, SQL Saturday’s and even made it to the PASS Summit a couple of times, but I’ve never contributed anything. It’s been all take.   Last year I got involved with dbatools and that started my quest to return the favour.  I’m still currently wrestling with the ideas of “who wants to listen to what I have to say” and “do I really have anything to contribute anyway,” but I’m doing my best to keep one foot in front of the other and see what happens.

Secondly, whenever I review my strengths and weaknesses at annual review time, communication, or more precisely public speaking is always something that I consider a weakness.  I’m not sure of a better way to improve in this area than to put myself out there and practice, so here’s to some professional development. I’m certain that gaining some knowledge, experience and confidence in this area will help me in many areas of my life.

## What to Present?

I ended up presenting on SQL Server data compression.  I talked about the types of data compression, and how the internals work before focusing on what you can compress, how to compress and how to decide what should be compressed.  This topic stemmed mainly from an issue at work where data compression was implemented with a large performance benefit.  This issue at work also encouraged me to spend some time looking at dbatools and compression. There were existing commands for Set-DbaDbCompression and Test-DbaDbCompression that I added some improvements to, and then I added Get-DbaDbCompression.

The culmination of both the issue at work and working on dbatools commands for compression left me feeling like this was a great topic to share.  Since 2016 SP1 data compression is now a standard level feature, opening up the possibilities to a lot more people.

## Improvements

Overall I think the presentation went well, I delivered most of what I had planned on saying and my demo’s did a decent job of explaining the process for deciding what to compress and then applying compression through T-SQL, SSMS and PowerShell.  I was lucky to have some great friends in the audience (Andrew, Drew and Erin) who asked great questions which helped me to drive home certain points.

My timing was definitely a bit off. I’d prepared for what I thought would be 45-60 minutes of content and it was a bit shorter than that.  I plan on adding some additional content and delivering slightly slower the next time I give this talk to fix this problem.

I got some great feedback both from the speaker evaluations and from [Erin Stellato](https://www.sqlskills.com/blogs/erin/) who went above and beyond my request for any tips and feedback she may have.  I’ll make sure to incorporate some real life stories on where compression has had an impact as well as adding some more demos.

## What’s next?

That’s right, there is a next! I took a chance and submitted my session to [SQL Saturday Columbus](http://www.sqlsaturday.com/736/eventhome.aspx) and was lucky enough to be selected.  I’ve been to quite a few SQL Saturdays in Cleveland, Columbus, Pittsburgh and even Minneapolis, but this will be my first as a speaker.  If you’re in the area on July 28th and want to learn more about data compression I’ll be on at 8:30am in Room 6.

I’m also going to work on some blog posts around data compression and the dbatools commands so watch out for that also.
