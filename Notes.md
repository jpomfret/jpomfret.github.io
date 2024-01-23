# Notes

- create dev container
- test it's installed `hugo version`
- make a site in the root `hugo new site blog`
- add a theme `git clone https://github.com/vaga/hugo-theme-m10c.git themes/m10c` -- do it as a module
- create a post `hugo new posts/examplepost.md`
  - change it from being a draft
- hugo server

- add `publishDir = "docs"` to config

## todo

SVG icons
https://heroicons.dev/?query=book
https://tablericons.com/

Copy an icon - save as an svg!

hugo server --poll=700ms -D

## Make a new post

hugo new post/2024/name-of-post/index.md

{{<
  figure src="tsqltues-300x300.png"
         link="https://garrybargsley.com/t-sql-tuesday-110-automate-all-the-things/"
         class="float-left"
         alt="T-SQL Tuesday Logo"
         width="300px"
         height="300px"
>}}
