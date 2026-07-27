# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

Personal blog for Jess Pomfret (jesspomfret.com), built with Hugo on the `hugo-theme-stack` v3 theme, consumed as a **Hugo Module** (not vendored). Content is the primary artifact; the site's own customization happens entirely through Hugo's file-precedence override mechanism rather than by forking the theme.

## Commands

All commands run from the `blog/` directory — that's the actual Hugo site root, not the repo root.

```
cd blog
hugo server --port 1313      # local dev server with hot reload, http://localhost:1313/
hugo                          # production build -> blog/public/
hugo --gc --minify            # matches the production build in .github/workflows/hugo.yml
```

Building requires both **Hugo Extended** and **Go** (Go resolves/downloads the theme module on first build; `blog/go.mod` declares `go 1.21` as the floor). No `hugo mod vendor` step is needed for normal work — see "This is a themed site" below for why not to run/commit that.

There is no working automated test suite. `tests/metadata.tests.ps1` is an incomplete Pester scaffold intended to validate post frontmatter (description, slug, tags); its current assertion is a stub that doesn't actually check anything. Changes are verified by building and visually checking the local dev server (both light and dark theme).

## Architecture

### This is a themed site, not a custom Hugo build

`hugo-theme-stack` (github.com/CaiJimmy/hugo-theme-stack, GPL-3.0) is a Hugo Module dependency declared in `blog/go.mod`. Its source is never vendored into this repo — don't run `hugo mod vendor` and commit the result; it permanently changes Hugo's module resolution for the project if the `_vendor/` directory is left in place, and was tried once during development and reverted.

All customization goes through Hugo's own override mechanism: a file placed at the same relative path under `blog/layouts/` or `blog/assets/` as a theme file takes precedence over the theme's copy. To see what the theme's original file looks like (needed before overriding something new), fetch it from GitHub rather than guessing:

```
gh api repos/CaiJimmy/hugo-theme-stack/contents/<path>?ref=v3.29.0 --jq '.content' | base64 -d
```

### Where the visual identity lives

- `blog/assets/scss/custom.scss` — almost all customization in one file: brand color tokens as CSS custom properties (separate light/dark pairs), self-hosted `@font-face` declarations (Etna for headings, Garet for body — see the `--heading-font-family` vs `--article-font-family`/`--base-font-family` split, and why: `--article-font-family` drives the theme's whole prose block, not just titles), and all `.changelog-*` component styles for the homepage feed. This file is `@import`ed last in the theme's SCSS chain, so it wins the cascade at equal selector specificity; a few overrides need matched/higher specificity or `!important` to beat a theme rule (noted inline where that's done, e.g. neutralizing the theme's default 5-color rainbow tag rotation).
- `blog/layouts/index.html` — replaces the theme's default homepage (card grid) with a changelog/release-notes feed (one hero + a list of entries).
- `blog/layouts/partials/article-list/{changelog-hero,changelog-entry}.html` — the two feed components. The hero's background is a fixed brand-kit image (`blog/static/img/hero-frame-{light,dark}.png`), not a per-post cover-image crop — that was tried first and abandoned because posts' own cover images have baked-in title/badge text that collided with the hero's own dynamic title.
- `blog/layouts/partials/head/head.html` — overrides the theme's `<head>` to drop the *unconditional* Google Analytics include.
- `blog/layouts/partials/footer/custom.html` — the theme's own designated (normally empty) extension point; holds the cookie-consent banner and the gated GA loader (only fires after "Accept", persisted in `localStorage`).
- `blog/layouts/partials/footer/components/custom-font.html` — overridden to a no-op; the theme's default here unconditionally fetches Google Fonts' Lato, which this site doesn't use anymore.

### Config is split across `blog/config/_default/*.toml`

Hugo merges every file in that directory; there is no single root `hugo.toml`.

- `config.toml` — root Hugo settings: `baseurl`, `capitalizeListTitles = false` (deliberate — without it Hugo auto-title-cases taxonomy terms, turning tags like `dbatools` into `Dbatools`), `googleAnalytics`, pagination.
- `params.toml` — theme params (sidebar, comments, per-article license text, widgets). `comments.enabled = false` is intentional and accurate, not a regression: Disqus was configured with `enabled = true` but no `disqusShortname` was ever set, so comments never actually loaded.

### Content structure

- `blog/content/post/<year>/<slug>/index.md` — Hugo page bundles; each post's images live alongside its `index.md` in the same folder.
- `blog/content/page/**` — standalone pages (Buy the Book, Finding Data Friends, archives, search).
- Real front matter fields in use: `title`, `slug`, `description`, `date`, `categories`, `tags`, `image` (cover), `draft`.
- Posts without enough headings for a real table of contents lose the theme's right-sidebar column entirely, and its main content column would otherwise stretch to fill the leftover width — `.article-page .main-article` in `custom.scss` caps that width to match normal (with-sidebar) posts.

### Licensing is intentionally split

- Code/templates: MIT (`LICENSE` at repo root).
- Blog post content (`blog/content/`): CC BY-NC-SA 4.0, stated per-article via `article.license.default` in `params.toml`. This split was a deliberate decision during the site's rebrand, not an inconsistency to "fix."

### Design system record

`PRODUCT.md` and `DESIGN.md` at the repo root are maintained by the "Impeccable" Claude Code design skill and record durable product truth and the shipped visual system respectively. Keep them in sync with major visual/product decisions made through that skill rather than letting them drift.

### Known local-environment quirk

`blog/assets/jsconfig.json` is gitignored on purpose — Hugo regenerates it on every `hugo`/`hugo server` run with a machine-specific absolute path into the Go module cache, so committing it just produces per-machine diff noise.
