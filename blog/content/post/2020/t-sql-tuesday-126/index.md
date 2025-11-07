---
title: "T-SQL Tuesday #126 – Folding@Home"
description: "What I'm doing in response to the COVID-19 pandemic."
slug: "t-sql-tuesday-126"
date: "2020-05-12"
categories:
  - "personal"
  - "t-sql-tuesday"
tags:
  - "tsql2sday"
---

{{<
  figure src="/tsqltues-300x300.png"
         link="https://glennsqlperformance.com/2020/05/05/t-sql-tuesday-126-foldinghome//"
         class="float-left"
         alt="T-SQL Tuesday Logo"
         width="300px"
         height="300px"
>}}

Well it’s May T-SQL Tuesday time! Honestly I’m not sure if time is crawling or flying by, it seems like forever ago we got writing for the April prompt on unit testing databases.  Thanks to Glenn ([b](https://glennsqlperformance.com/)) this month for hosting an interesting topic. I’m looking forward to reading all the responses. Also a bigger thanks for publicising [Folding@Home](https://foldingathome.org/) and setting up the [#SQLFamily](https://stats.foldingathome.org/team/236388) team!

Glenn wants to know what we’re doing in response to COVID-19 and if we’re contributing to the FAH #SQLFamily team, what our experience has been.

## Folding@Home

I installed the Folding@Home client almost a month ago now on my Intel NUC. The NUC is connected up to my TV and mainly used as a media server. Occasionally I’ll use it to build out a lab to test something but most of the time it’s idle. Perfect to donate.

My FAH setup is pretty standard. I installed the client, requested a passkey, and set it loose. One thing I am a little uncomfortable with is the CPU is at 100% all the time FAH is running a workload, and it gets a little hot.  I started manually setting the workload to ‘finish’ (finish the workload currently running but then pause) in the evenings and then setting it back to ‘fold’ in the morning.

Since I’m human, sometimes I forgot.

Enter PowerShell.

I found that you could pass commands into the FAHClient.exe and therefore set the status from PowerShell.  I created a simple module [PsFah](https://github.com/jpomfret/PSFah) with a function to control the FAH client Status. When I say simple, it currently has one function that sets the local client status to fold, pause or finish. Perhaps I’ll add more over time (I started getting more side-tracked by this and then realised I needed to actually write this post).

I then set up two scheduled tasks (details below) that set the client to start folding at 7am and then set it to finish folding at 8pm. Removing the human, and therefore improving the process.

```PowerShell
$taskSplat = @{
    Action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument 'Set-FahStatus -Status Fold'
    Trigger = New-ScheduledTaskTrigger -Daily -At '07:00'
    Description = 'Start Folding'
    Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

}
Register-ScheduledTask @taskSplat -TaskName 'Start Folding'

$taskSplat = @{
    Action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument 'Set-FahStatus -Status Finish'
    Trigger = New-ScheduledTaskTrigger -Daily -At '20:00'
    Description = 'Finish Folding'
    Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
}
Register-ScheduledTask @taskSplat -TaskName 'Finish Folding'
```

## Community Involvement

{{<
  figure src="DW_Speaker-1.jpg"
         class="float-left"
         alt="data weekender camper van"
         width="300px"
         height="300px"
>}}

Another way I’ve been trying to give back a little is with community involvement. I was lucky enough to be selected to speak as part of the [Data Weekender](https://www.dataweekender.com/) event. It was great to be able to deliver a session and share some dbatools knowledge. It was even better to watch some sessions and chat with the community. I miss that interaction that you get at conferences, and this day helped to fill that void – if only virtually.

I am also really excited to be speaking at the [GroupBy conference](https://groupby.org/may2020-schedule/), which when this post goes live will be today!

I enjoy travelling and speaking and I was really disappointed that I had been selected to speak at a couple of events that were then cancelled because of COVID. Being able to still speak and contribute to the community virtually has been a really great experience.

## Finally

It’s easy to feel like you’re not doing enough during this crisis. it’s hard to stay motivated and to be productive when there is so much stress and anxiety in the world.  First things first, we have to look after ourselves and our people. If you have extra energy left over there are plenty of ways to give back, but it’s important for all of us to remember that just surviving right now takes more energy than usual.

Stay safe folks.
