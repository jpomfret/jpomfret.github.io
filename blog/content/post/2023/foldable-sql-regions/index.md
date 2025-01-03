---
title: "Foldable SQL Regions"
slug: "foldable-sql-regions"
description: "Using foldable regions in VSCode or Azure Data Studio to make our T-SQL easier to navigate. "
date: 2023-06-09T15:14:22Z
categories:
    - t-sql
    - azure-data-studio
    - vscode
tags:
    - t-sql
    - azure-data-studio
    - vscode
image: jj-ying-WmnsGyaFnCQ-unsplash.jpg
draft: false
---

VSCode is always my go-to editor these days, for PowerShell, T-SQL, even when I just need to make a few plain text notes. I'm pretty sure not a day goes past where I don't have at least two different VSCode windows open. If you aren't already using VSCode, please go check it out at [VSCode](https://code.visualstudio.com/).

There are many VSCode tips and tricks I want to share, but this is just a quick post about something I learnt today!

## Foldable PowerShell Regions

I've used VSCode for PowerShell code for a long time now and I'm well aware that you can create regions in your code. If I surround this bit of [dbatools](https://dbatools.io/) code with `#region` to start and `#endregion` to finish, in the gutter an arrow will appear which you can use to fold the code.

```PowerShell
#region
try {
    $databases = $server.Databases | Where-Object IsAccessible -eq $true
    if ($Database) {
        $databases = $databases | Where-Object Name -In $Database
    }
} catch {
    Stop-Function -Message "Error occurred while getting databases from $instance" -ErrorRecord $_ -Target $instance -Continue
}
#endregion
```

You can see I've highlighted the gutter and the arrows point right if the code is folded, and down if it's currently open. You'll also notice that VSCode gives you the option to fold other parts of your code automatically, for example, try\catch blocks.

> Note: You do have to hover your mouse in the gutter to see the arrows.

{{<
  figure src="foldedPowerShell.jpg"
         alt="Two PowerShell snippets, one folded and one open"
>}}

## Foldable T-SQL Regions

Today I was tasked with going through a long T-SQL script, and I found myself getting lost and wishing I could section the code off somehow to make it easier to navigate. I did a quick Google and found regions work in T-SQL too, just the syntax was slightly different which is why my previous attempts had failed.

To create the foldable regions you'll use `--#region` to start and `--#endregion` to end. You can also name the regions, which I would recommend as it helps identify the code within the region when it is folded up.

```SQL
--#region create job
--// Create Job
EXEC jobs.sp_add_job @job_name = @JobName,
     @description = @JobDescription,
     @enabled = @Enabled,
     @schedule_interval_type = @ScheduleIntervalType,
     @schedule_interval_count = @ScheduleIntervalCount,
     @schedule_start_time = @ScheduleStart
;
GO
--#endregion
```

{{<
  figure src="foldedSQL.jpg"
         alt="Some T-SQL code with folded and open sections, with red arrows highlighting the region tags"
>}}

## Final Good News

Since [Azure Data Studio](https://github.com/microsoft/azuredatastudio) (ADS) is based on the VSCode codebase foldable T-SQL regions work there too!

I wonder if as we start using ADS more and more whether it should be considered a best practice not just to comment you T-SQL code but to add regions too, increasing the readability for the next person who comes along.

{{<
  figure src="azureDataStudio.jpg"
         alt="Some T-SQL code with folded and open sections, with red arrows highlighting the region tags"
>}}