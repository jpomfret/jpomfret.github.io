# Jess Pomfret Blog

The domain glossary for jesspomfret.com: a personal technical blog built with Hugo on the `hugo-theme-stack` theme. This file is a glossary, not a spec — it fixes the vocabulary so the docs, the code, and future conversations use the same words for the same things. Implementation lives in [CLAUDE.md](./CLAUDE.md); the visual system in [DESIGN.md](./DESIGN.md); product intent in [PRODUCT.md](./PRODUCT.md); durable decisions in [docs/adr/](./docs/adr/).

## Content

**Post**:
The unit of published content: a Hugo page bundle at `blog/content/post/<year>/<slug>/index.md`, with its images alongside it in the same folder. The canonical noun — front matter, URLs, and config all say "post."
_Avoid_: Article (that's the theme's word), entry (that's presentation — see Changelog entry).

**Changelog entry**:
A Post *as rendered in the homepage feed* — a dated, tag-pilled row. It is a presentation of a Post, not a separate kind of content. The "changelog" framing is a homepage metaphor ("The Shipped Log"), not the content model.
_Avoid_: Using "entry" to mean the content itself; the content is a Post.

**Hero** (a.k.a. **Latest entry**):
The single most-recent Post at the top of the homepage feed, rendered large on the fixed Brand-Kit frame card. Exactly one per page. The one deliberately saturated surface — see ADR-0003 and DESIGN.md.

**Page**:
Standalone content that is *not* a Post: Buy the Book, Finding Data Friends, archives, search (`blog/content/page/**`). Pages do not appear in the changelog feed.

## Theme & customization

**Theme**:
`hugo-theme-stack` (v3), consumed as a Hugo Module (a Go dependency), never vendored into this repo. See ADR-0001.

**Override**:
A file placed under `blog/layouts/` or `blog/assets/` at the *same relative path* as a theme file, so Hugo's file-precedence rules make it win over the theme's copy. This is the only customization mechanism used — the theme is never forked or edited in place.

## Brand & visual system

**Brand Kit**:
The external PersonalBrand visual-identity folder (octopus mark, four-color palette, Etna/Garet fonts, wave/tentacle/bubble elements). Binding visual authority for the redesign — the source of truth for *what* the brand is; DESIGN.md records *how* it's applied.

**Acting accent**:
The palette role that leads in a given theme: Octopus Purple in light mode, Signal Teal in dark mode. "Accent" is a role that swaps by theme, not a fixed color.

**Single-teal tag rule**:
Every category and tag pill sitewide is one teal, overriding the theme's default per-term color rotation. One color per taxonomy element, no exceptions.

**Preserved casing**:
Tags and categories render in their authored casing (`capitalizeListTitles = false`), so real tool names like `dbatools` stay lowercase. A deliberate behavior, not a bug.

## Licensing

**Code license**:
MIT, covering templates and code (root `LICENSE` file). Freely reusable.

**Content license**:
CC BY-NC-SA 4.0, covering blog prose (`article.license.default` in `params.toml`). The split from the code license is intentional — see ADR-0004.
