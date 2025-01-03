---
title: "T-SQL Tuesday #133: What (Else) Have You Learned from Presenting?"
description: "Some things I've learnt about while presenting."
slug: "t-sql-tuesday-133"
date: "2020-12-08"
categories:
  - "presenting"
  - "t-sql-tuesday"
tags:
  - "presenting"
  - "t-sql-tuesday"
image: "pexels-photo-459301.jpeg"
---

{{<
  figure src="/tsqltues-300x300.png"
         link="https://lisagb.info/archives/77/"
         class="float-left"
         alt="T-SQL Tuesday Logo"
         width="300px"
         height="300px"
>}}

It’s December, the last T-SQL Tuesday for 2020. I’ve managed to participate in seven this year, including hosting in February – I wonder if in 2021 I will be able to complete a full year. I always look forward to these monthly blog parties, so thanks to Lisa for hosting this month.

Lisa has asked us to share something we’ve learnt from presenting that didn’t relate directly to the topic we were presenting on.  I think this is a great topic. We already know that to present on a topic you have to really know it, so preparing for a presentation does wonders for your own personal knowledge on that topic.  Lisa has identified another bonus- all the ancillary knowledge that comes along with it.

I gave my first presentation in June 2018, and although it’s only been around 2.5 years since then, I have learnt so much from both presenting and contributing to the community.  I have a couple of areas I’m going to mention here.

## Git & GitHub

My first real contributions were not presenting but writing code and tests for dbatools.  Writing PowerShell was not something that was new to me, so I felt comfortable writing the function I wanted to add. Through code review it did get some much needed tweaking to ensure it met the standards and format of the project.  Getting the code from my laptop into the dbatools GitHub repo was another story – it was totally foreign to me.

Luckily the dbatools team is fantastic. They have written great guides on using git and GitHub in order to make your first pull request, and Chrissy even coached me through how to get my code into GitHub that first time.

As I continued to contribute I got more familiar with using Git and GitHub for source control, and since then there have been many times where I’ve needed that knowledge both for community projects as well as my real job. I even host my [presentation demos and slides](https://github.com/jpomfret/demos) there now.

## Docker

I think one thing that every presenter has had to learn is how to set up some form of a lab to be able to run demos in a reliable and repeatable way.  I started off with a VM on my local laptop that I could connect to and run demos against. This took some learning to get the networking setup. Something I still consider a weak area!

After a while I started reading more about containers, and specifically running SQL Server in containers.  I now (where possible) run all my demos for presentations against demo environments in containers that run on my laptop. I have already written a post on this, [Data Compression Demos in Containers](https://jesspomfret.com/data-compression-containers/), but this has given me a great opportunity to learn and play with a really interesting technology.

One of the main benefits I see when running demos against containers is how easy it is to wipe away your practice runs and have a fresh environment ready for the presentation.  I’ve even built pester tests into my setup script to ensure everything is in the perfect state for the demo gods. I’ve also written about that if you’re interested in what I test, [Keeping the demo gods at bay with Pester](https://jesspomfret.com/demo-gods-pester/).

## Summary

It took me a long time to make the first step into giving back and presenting content in front of people, but if I look back at the fun I’ve had over the last 2.5 years and all the knowledge I’ve gained it’s easy to see what a great decision that was. If you are considering speaking I would highly recommend giving it a go – as Lisa mentioned in her prompt, Allen White’s famous speech, everyone has something to teach.

Thanks again for hosting Lisa, and I look forward to reading all the other responses.
