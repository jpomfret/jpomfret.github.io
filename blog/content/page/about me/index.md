---
title: "About Me"
slug: "about"
date: 2026-11-01
layout: about
# Don't copy the raw photo originals (one is ~6.5MB) into the built site — the
# page only ever uses Hugo's processed/resized variants (.Resize), which are
# still published because they're referenced. Keeps the deploy lean.
build:
    publishResources: false
menu:
    main:
        weight: 5
        params:
            icon: about
about:
    # --- Hero ---------------------------------------------------------------
    name: "Jess Pomfret"
    # One punchy line: who you are + the vibe. Keep it short — it sits on
    # the brand frame. e.g. "Database engineer, dbatools maintainer, and
    # serial sunrise-chaser."
    tagline: "Database Engineer with a passion for automation,<br>proper football and fitness."
    # Microsoft MVP badge in the hero (links to your MVP profile). Remove this
    # line to hide the badge.
    # mvpUrl: "https://mvp.microsoft.com/en-US/MVP/profile/d54be54a-7042-ea11-a813-000d3a8cc191"

    # --- What I do (4 cards) ------------------------------------------------
    # Write ~1–2 sentences per card. Titles are fixed; links are already wired.
    cards:
        - title: "Database Engineering"
          body: "I work as a consultant for The Masterminds Group, helping clients with various data platform problems - troubleshooting issues, coordinating migrations, performing health checks for SQL Server, Azure environments and more."
          link: "https://masterminds.io/"
          linkText: "The Masterminds Group" 
        - title: "dbatools & Automation"
          body: "Contributing to dbatools and open source modules got me involved in the data community. dbatools is something I still use almost every day. If you're working with SQL Server and you haven't tried it out, go do that now. Trust me!"
          link: "https://dbatools.io"
          linkText: "dbatools.io"
        - title: "Speaking & Community"
          body: "I love speaking and giving back to the community. I try to attend several conferences a year, and I also co-host the Finding Data Friends podcast. I'm also a Microsoft MVP for both Data Platform and Azure disciplines."
          link: "/fdf"
          linkText: "Finding Data Friends"
          link2: "https://mvp.microsoft.com/en-US/MVP/profile/d54be54a-7042-ea11-a813-000d3a8cc191"
          link2Text: "Microsoft MVP Profile"
        - title: "Author & Courses"
          body: "I'm still so proud of 'Learn dbatools in a Month of Lunches', a book I co-authored. I also have several LinkedIn Learning courses I've written and recorded."
          link: "/book"
          linkText: "The book"
          link2: "/video"
          link2Text: "LinkedIn Learning"

    # --- Life outside the terminal (3 photo rows) ---------------------------
    # Titles are starting suggestions — edit freely. Write a short caption /
    # story for each (1–3 sentences).
    photos:
        - src: "IMG-20260620-WA0076.jpg"
          title: "Chase the Sun - June 2026"
          alt: "Me and Pete at the Chase the Sun finish line on the Weston-Super-Mare pier"
          caption: "205 miles, East coast to West coast, sunrise to sunset - what a day on the bike!<br><br>This was an incredible physical and mental challenge. I spent months training for this day. I'm also super proud of the amount of money we raised for [Momentum Fitness Charity](https://www.momentumfitnesscharity.org.uk/)."
        - src: "PXL_20261018_074743877.MP.jpg"
          title: "On two wheels"
          alt: "Sprucey, my best bike leaning against a Hampshire signpost at sunrise"
          caption: "Cycling is something I love for fitness, but also just to be outside. I live in a beautiful part of the world.<br><br> Here's Sprucey, my best road bike, somewhere in the South Downs national park at sunrise. One of my favourite places to be.<br><br>I'm definitely an early morning person, and getting out on my bike before the rest of the world wakes up is something I do often, especially in the summer months."
        - src: "PXL_20230427_093959842.jpg"
          title: "Exploring the world"
          alt: "Jess and Kelc on the Spanish Steps in Rome, azaleas in bloom"
          caption: "My wife Kelc and me, in Rome. Travelling the world together is something we prioritise.<br><br>We love exploring new countries, enjoying food and pastries and generally having a good time."

    # --- Currently (facts strip) -------------------------------------------
    # Short values. Delete any line you don't want; add your own label/value.
    currently:
        - label: "Based in"
          value: "Hampshire, UK"
        - label: "Day job"
          value: "Data Platform Engineer"
        - label: "Currently riding"
          value: "Specialized Tarmac, Spruce Green!"
        - label: "Currently reading"
          value: "Dungeon Crawler Carl"
        - label: "Fuelled by"
          value: "Coffee"
        - label: "Find me at"
          value: "SQL Konferenz"

    # --- Closing ------------------------------------------------------------
    # A warm one-liner sign-off. Socials below are pulled in automatically.
    closing: "Connect with me on socials, and let's chat at the next data conference."
---

Hey folks!

I'm Jess Pomfret, my pronouns are She/Her and I've worked in and around data since 2011. I started as a SQL Server Database Administrator, in an environment that had absolutely everything. SSIS, SSRS, Replication, you name it, and what a great place it was to learn. I worked in a few similar positions over the years, learning more about cloud technologies and automation. Getting involved with dbatools really opened my eyes to what PowerShell could do for DBAs, and as someone who hates manual tasks I found my niche.

Since then I've gone deeper into cloud technologies, DevOps and Kubernetes. My passion is solving problems, fixing broken technology and helping my clients get their environments into perfect working order.

I grew up in Chippenham, Wiltshire in the UK, but moved to Akron, Ohio, USA when I was 19 on a football/soccer scholarship. After meeting my wife in 2015 we decided to move to Hampshire, UK in 2020 and have lived here since.