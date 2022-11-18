---
title: "Using Extended Events to determine the best batch size for deletes"
date: "2021-12-07"
categories:
  - "xevents"
tags:
  - "extended-events"
  - "tsql"
image: "hans-reniers-lQGJCMY5qcM-unsplash.jpg"
---

I found myself needing to clear out a large amount of data from a table this week as part of a clean up job.  In order to avoid the transaction log catching fire from a long running, massive delete, I wrote the following T-SQL to chunk through the rows that needed to be deleted in batches. The question is though, what’s the optimal batch size?

It’s worth noting that an index on the date column was required for this to be as efficient as possible. The table I was deleting from had 4 billion rows and I didn’t want to scan that each time!

DECLARE @Before      DATE = DATEADD(DAY,-30,GETDATE()),
        @BatchSize   INT  = 50000

WHILE (1=1)
BEGIN

    DELETE TOP (@BatchSize) t
    FROM dbo.bigTable t
    WHERE Date < @Before

    -- if we deleted less than a full batch we're done
    IF @@rowcount < @BatchSize
            BREAK;

    -- add a delay between batches
    WAITFOR DELAY '00:00:01'
END

Time for a science experiment. The easiest way to determine the optimal batch size is to run some tests. I decided to test deleting in batches of 10k, 25k, 50k and 100k and measure the delete durations with extended events.

My goal was two part - to delete as many rows as possible in a two-hour maintenance window, but also to reduce the amount of time locks were held on the target table.

The following T-SQL creates an extended events session that captures one event, `sqlserver.sql_statement_completed`, and filters on both my username and the statement like ‘delete top%’. I didn’t choose a target as I just chose to watch the live data, but you could easily add an event\_file if you want to persist the data.

CREATE EVENT SESSION \[DeleteExperiment\] ON SERVER
ADD EVENT sqlserver.sql\_statement\_completed(SET collect\_statement=(1)
    ACTION(sqlserver.nt\_username)
    WHERE (\[sqlserver\].\[equal\_i\_sql\_unicode\_string\](\[sqlserver\].\[session\_nt\_user\],N'JessUserName')
   	AND \[sqlserver\].\[like\_i\_sql\_unicode\_string\](\[statement\],N'delete top%')
   	)
)
GO

Once the extended events session had been successfully created and was running, I opened the ‘Watch Live Data’ pane and started running my deletes in another window.  I left each experiment running for a while to make sure I got a decent sample size for each batch size.

Once I’d cycled through the different batch sizes, I used the grouping and aggregation features in the Extended events wizard, shown on the toolbar below:

![](https://lh6.googleusercontent.com/1tCeCwFt3DECWGZha_oV0qjLs0tYq3d3JSxccZc7Fy931ZkgvrMeZrn0665AOrR4GtFe0kBEPgrwBSNcGbx7-axO5QflWksX6BkB58AF6gvydBSV-7S0lrMfwSwIH2qBp1Jm6K7N)

I grouped by ‘last\_row\_count’ which is my batch size, and then calculated the average duration for each group. You can see in the screenshot below the values for each.

![](https://lh5.googleusercontent.com/uku5O7ozzE8RSSh1ehpNdNj5EEWdizFtbC0ndXZfPMh5G5zCSEsIP8Vk3R3sdt7c3DsGf9If2__M7LdmjQ3WHSce5LDjMyhtRbmxLLPmOtMF4XVWlGovW3ZdDaTUIn3l-pwMOUXI)

The duration unit is microseconds for the sp\_statement\_completed event so after some squinting and calculations the results are as follows:

| Batch Size | Average Duration (Seconds) |
| --- | --- |
| 10,000 | 0.46 |
| 25,000 | 1.74 |
| 50,000 | 3.31 |
| 100,000 | 7.57 |

For now, I’ve decided to go with batches of 50,000 for the deletes. Depending on how things go I might change this to 25,000 as in my mind both those batch sizes met my criteria.

Hope this blog post has given you some ideas for testing out different scenarios with Extended Events.
