---
title: "Execution of Multiple Triggers on one Table"
date: "2019-05-08"
categories:
  - "triggers"
tags:
  - "triggers"
---

Well it has been a little quiet here recently. I just (or it’s been two weeks now) got back from a 2 week trip to England and France. It was an amazing trip and there are a few pictures on [Instagram](https://www.instagram.com/jpomfret/) if you are curious about what I got up to.

This is also going to be a quick post. I asked a question on Twitter last week about what happens when you have multiple triggers on a table. I got the answer (Thanks Aaron!), but figured this would be a good thing to demonstrate.

{{< tweet user="AaronBertrand" id="1121436026956861445" >}}

I have also been playing with Azure Data Studio and the new notebook feature, so I answered this question with a step-by-step example in a notebook. I also found that you can easily store these notebooks on GitHub so I have uploaded it to my demos repo for you to follow along.

[Trigger Order Notebook](https://github.com/jpomfret/demos/blob/master/Notebooks/TriggerOrder.ipynb)

TL;DR: Triggers execute one after the other. I demonstrated this by creating a table with three insert triggers that each waited 2 seconds and recorded the timestamp.
