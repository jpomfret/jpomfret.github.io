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

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">One at a time. You can control first and last but that's it - the middles will run in an arbitrary / non-deterministic order. If you have &gt; 3 I don't know that order is going to be your biggest problem. :-) <a href="https://twitter.com/hashtag/sqlhelp?src=hash&amp;ref_src=twsrc%5Etfw">#sqlhelp</a></p>— Aaron Bertrand (@AaronBertrand) <a href="https://twitter.com/AaronBertrand/status/1121436026956861445?ref_src=twsrc%5Etfw">April 25, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

I have also been playing with Azure Data Studio and the new notebook feature, so I answered this question with a step-by-step example in a notebook. I also found that you can easily store these notebooks on GitHub so I have uploaded it to my demos repo for you to follow along.

[Trigger Order Notebook](https://github.com/jpomfret/demos/blob/master/Notebooks/TriggerOrder.ipynb)

TL;DR: Triggers execute one after the other. I demonstrated this by creating a table with three insert triggers that each waited 2 seconds and recorded the timestamp.
