---
title: "Advent of Code 2020"
descripton: "A few PowerShell tips I learnt while participating in the Advent of Code 2020 puzzles."
slug: "advent-of-code-2020"
date: "2020-12-31"
categories:
  - "powershell"
tags:
  - "adventofcode"
  - "aoc"
  - "powershell"
image: "cover.png"
---

This was the 3rd year I participated in the [Advent of Code](https://adventofcode.com/) (AoC). If you haven’t heard of AoC, it’s an advent calendar of coding puzzles.  Each day between December 1st and 25th a two part puzzle is released, you can use whatever language you want to solve it, with the goal being just to get the right answer.  Once you solve part 1 for the day, part 2 is unlocked and that builds on top of the story you had for part 1. For each part of each puzzle you complete you get a star, so there are two available per day.

This year I managed to complete both parts of the first 9 days of the calendar, and then just the first part of days 10 and 15, that’s 20 total stars out of a possible 50.  That doesn’t sound great, less than 50%, so why am I writing a blog about this mediocre performance?

My goal was to gain more stars than last year, which I succeeded at. I only got 6 total stars last year. Now my goal for next year will be to beat this year's performance.  I did learn several neat things while working on these puzzles and those I thought were worth sharing.

## Named Loops in PowerShell

A lot of the puzzles involve iterating over an object and manipulating it. I depended on a lot of loops for this. My day 1, part 1 solution is below.  You can see I nested two loops to iterate over the array and calculate the total. Without the named loops this worked – it just didn’t stop when it found the correct answer and I got duplicates.  By naming the outer loop with `:expenses` you can then break all the way out of that loop with `break expenses`.  Pretty useful!

```PowerShell
$expenses = Get-Content .\Day01\Input.txt

# Part 1 - 514579
:expenses
foreach ($e in $expenses) {
    foreach ($f in $expenses) {
        if ([int]$e + [int]$f -eq 2020) {
            ("Part 1 answer: {0}" -f ([int]$e \* [int]$f))
            break expenses
        }
    }
}
```

## Split string into multiple variables at once

A lot of the puzzles input required some string manipulation. Some of this I used regex for, and if it wasn’t that complicated I could use the split method.  Previously I had always split strings into variables by first splitting into an array, and then specifying the index of the item for each variable:

```PowerShell
$split = ('test string').split(' ')
$firstVariable = $split[0]
$secondVariable = $split[1]
```

PowerShell has an easier option though- you can accomplish this same behaviour with just one line:

```PowerShell
$firstVariable, $secondVariable = ('test string').split(' ')
```

## Split a string into a maximum number of substrings

Another string splitting tip is if you only want to split a certain number of times there is an overload for the string method for that. I have used the split method for years, but I have never looked any further into what it can do.  A handy reminder that reading the docs for even simple methods/functions is a worthwhile endeavour (perhaps a 2021 goal?!?).  

```PowerShell
('I only want two substrings').split(' ',2)
```

This results in:

I
only want two substrings.

## I’m not a Computer Scientist

The final thing I learnt is that I’m not a computer scientist.  The first few days of puzzles were pretty straightforward – I had no problem working out what was needed and writing a solution.  Was it the most effective and beautiful code ever, probably not, but it got the right answer and that was all we needed.  Once we got into the second week the difficulty picked up- I didn’t study maths or computer science and found I was severely lacking when it came to needing more complicated algorithms to solve the puzzles.

That’s ok though. Although it’s definitely a gap in knowledge when it comes to solving code puzzles, it hasn’t really caused problems or issues in my day to day work. I’m still able to use PowerShell to automate tasks and manage a large database estate.

Saying that, I am interested in learning more about these topics. I love a puzzle and the Advent of Code is a great way to finish the year with some challenges and learning.

If you're interested in my efforts, all of my code is on [Github](https://github.com/jpomfret/AdventOfCode).
