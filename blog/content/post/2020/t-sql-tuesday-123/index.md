---
title: "T-SQL Tuesday #123: Life hacks to make your day easier"
description: "It's my turn to host the blog party and I'm looking for your life hacks!"
slug: "t-sql-tuesday-123"
date: "2020-02-04"
categories:
  - "t-sql-tuesday"
  - "vscode"
tags:
  - "tsql2sday"
  - "vscode"
---

{{<
  figure src="/tsqltues-300x300.png"
         class="float-left"
         alt="T-SQL Tuesday Logo"
         width="300px"
         height="300px"
>}}

It’s time for the February edition of T-SQL Tuesday. I am really grateful to be able to host this edition and look forward to reading everyone’s contributions. In case you are new to T-SQL Tuesday this is the monthly blog party started by Adam Machanic ([b](http://dataeducation.com/)) and now hosted by Steve Jones ([b](https://voiceofthedba.com/)). It’s a way of encouraging blog posts from the community and helping to share the knowledge.

So here we are, the first Tuesday of February. I personally always find February to be the month where my motivation is a little low. I live in the northern hemisphere so it can be a pretty dreary winter month where it still feels like there is a long way to spring (I will say this January I moved from Ohio back to England and the distinct lack of piles of snow is helping this cause somewhat). This makes my topic even more relevant as we need a little extra help to be productive and get through the month.

My topic is looking for your favourite ‘life hack’, something you use to make your day easier. This could be anything from a keyboard shortcut in SSMS that runs ‘sp\_whoisactive’, to a technique you use to get and stay organised.  It doesn’t have to be directly related to a technology, just whatever you use to make your life easier.

Now, I’m personally a huge proponent of using keyboard shortcuts to get things done faster. In the last year or so I’ve started using Visual Studio Code as my editor of choice and the number of little ‘life hacks’ I’ve found has grown incredibly. I’m going to share a couple that I use often to get your ideas flowing.

## Multiline Select - Ctrl + Alt+ Direction Key

This is something I love for formatting queries, among other things. I know you can use T-SQL to generate some queries from the metadata but if you have a list of tables you want to truncate, for example, you can easily accomplish this. Select the start of each line by using Ctrl + Alt + down direction key, add the `TRUNCATE TABLE` text and then press end to get to the end of each line, no matter the length, to add the semicolon.

![Using Multiline select in VSCode](https://media.giphy.com/media/adZdbCnMHbvc6TMjVi/giphy.gif)

The other use I have for this hack is to generate names and descriptions of Active Directory groups for tickets to have them created.  At my previous job we created read and admin groups for databases that users could then request access to. Multiline select made this really easy to generate the required information.

You can use multiline select at the beginning of the row. Start by selecting the first word and copying it (Ctrl+C), then you can type to format your group name. For example, I put `SqlDb-` before the database name and then `-Read` afterwards.  Pressing enter at the end of the group name will create a second line for all three groups where you can add the description. Notice I can now use paste (Ctrl+V) to add the database name that we copied from each line.

![A more complicated example of multiline select](https://media.giphy.com/media/6VIFc47iqYEVI4br5J/giphy.gif)

This ability to change multiple lines at once is really powerful and once you get the hang of what you can do with it you’ll find so many opportunities.

## Change all occurrences – Ctrl + F2

A similar hack to my first, VS Code also lets you change multiple occurrences of characters. I say characters because you can select whole words, parts of words, or even punctuation. This is really handy, for example, for formatting a comma separated list on one row into a list with each value on a separate row.

Carrying on from my previous example, now that we have formatted the group names and description. I can select the word ‘Read’ and replace all with ‘Admin’. Just like that I have all I need to get the group request off to the help desk for creation.

![Changing all occurances of a word in VSCode](https://media.giphy.com/media/S1w7CIkPRkOkN02mq4/giphy.gif)

## Command Palette -  F1 or Ctrl+Shift+P

VS Code also has a really great Command Palette that offers a lot more for you to explore. A few of my favourites are:

- **Sort Lines Ascending/Descending** – Select some lines in VS Code and easily alphabetise them.
- **Git: Undo Last Commit** – Rescue that last commit back from your source control. Useful if you realised a second too late you committed to the wrong branch.
- **File: Compare Active File With** – This clearly highlights differences between two files.

## Over to you

I hope my VS Code life hacks have got your ideas flowing, so now it’s over to you. Finally, the important part, the rules. You can [read the full rules here](http://tsqltuesday.azurewebsites.net/rules/), but the keys are:

- Write about the topic described above
- Include the T-SQL Tuesday Logo and link back to this post
- Comment on this post so I make sure not to miss your contribution
- Post your blog on February 11th between 0:00 - 23:59 UTC

If you have an idea for a future T-SQL Tuesday you can [contact Steve Jones](http://tsqltuesday.azurewebsites.net/contact/).

## Bonus February Fact

Just in case anyone is still reading, while I was looking for a nice way to tie my topic to the month of February I discovered that one of the old English names for this month was Kale-monath, which means “cabbage month.” As if February couldn’t get any worse! This doesn’t really tie my topic and February together, just a useless fact to add to your collection. You’re welcome!
