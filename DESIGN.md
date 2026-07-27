---
name: Jess Pomfret — Changelog Blog
description: A living changelog of practical SQL Server, Azure, and dbatools automation work, marked by a purple octopus.
colors:
  brand-purple: "#530080"
  brand-purple-deep: "#38005a"
  brand-navy: "#10265d"
  brand-lightblue: "#bdecfe"
  brand-teal: "#4faab3"
  brand-teal-bright: "#7dc4cb"
  brand-ink: "#06171f"
  body-background-light: "#eef7fb"
  card-background-light: "#ffffff"
  card-text-main-light: "#10203f"
typography:
  headline:
    fontFamily: "Etna, var(--base-font-family)"
    fontSize: "3rem"
    fontWeight: 700
    lineHeight: 1.2
  title:
    fontFamily: "Etna, var(--base-font-family)"
    fontSize: "2rem"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "Garet, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "var(--code-font-family)"
    fontSize: "1.3rem"
    fontWeight: 700
rounded:
  tag: "6px"
  card: "14px"
components:
  changelog-tag:
    backgroundColor: "{colors.brand-teal}"
    textColor: "{colors.brand-ink}"
    rounded: "{rounded.tag}"
    padding: "4px 10px"
  changelog-category-pill:
    backgroundColor: "rgba(79, 170, 179, 0.15)"
    textColor: "#0d4a50"
    rounded: "{rounded.tag}"
    padding: "4px 12px"
  changelog-entry-card:
    backgroundColor: "{colors.card-background-light}"
    textColor: "{colors.card-text-main-light}"
    rounded: "{rounded.card}"
    padding: "var(--card-padding)"
  changelog-hero:
    backgroundColor: "linear-gradient(135deg, {colors.brand-purple} 0%, {colors.brand-navy} 100%)"
    textColor: "#ffffff"
    rounded: "{rounded.card}"
    padding: "calc(var(--card-padding) * 1.4)"
---

# Design System: Jess Pomfret — Changelog Blog

## Overview

**Creative North Star: "The Shipped Log"**

The site presents Jess's technical work as an ongoing changelog, not a magazine of interchangeable cards. A fixed sidebar carries the purple octopus mark, name, and socials as constant identity; the main pane is a chronological feed that opens on one always-saturated "latest entry" hero and settles into dated, tag-pilled entries below it. The world runs on a full four-color palette (purple, navy, light-blue, teal) where every hue is an assigned role rather than a decorative accent, paired with two self-hosted brand fonts: Etna Sans Serif for anything that names a thing (headlines, titles) and Garet for anything that explains it (body copy, excerpts).

The hero is the system's one deliberately committed, theme-independent moment: it always renders on the purple-to-navy gradient regardless of whether the visitor is in light or dark mode, then hands off through a real wave-art image divider into the ordinary token-driven feed. Everything past the wave is flat, quiet, and legible; the saturation is spent entirely on the hero so it doesn't leak into the rest of the page.

**Key Characteristics:**
- Full-palette role assignment: purple leads in light mode, teal leads in dark mode, navy and light-blue are the two grounds.
- One fixed-gradient hero per page, everything else theme-responsive.
- Etna for names (headlines/titles), Garet for explanations (body/excerpts).
- Dated, tag-pilled entries in place of a generic card grid.
- Real Brand Kit wave artwork as the only divider in the system.

## Colors

Four named roles cover the whole system; nothing is an unassigned accent, and the acting accent itself swaps by theme.

### Primary
- **Octopus Purple** (`#530080`): the light-mode acting accent — link/hover color, dated tag pill background, and one leg of the hero gradient. Has a deeper hover/active state, **Purple Deep** (`#38005a`).

### Secondary
- **Signal Teal** (`#4faab3`): the dark-mode acting accent (contrast-checked against navy body text), and, regardless of theme, the fixed color of every category/tag pill sitewide (the theme's default per-tag rainbow rotation is overridden to this single teal). A brighter variant, **Teal Bright** (`#7dc4cb`), marks the hero's "Latest entry" eyebrow label.

### Tertiary
- **Brand Navy** (`#10265d`): the dark-mode page ground and the second leg of the hero gradient in both themes.
- **Brand Light-Blue** (`#bdecfe`): the dark-mode body-text tint and the category-pill color inside the hero (which needs gradient-safe colors independent of the light/dark card tokens).

### Neutral
- **Water Tint** (`#eef7fb`): light-mode page ground.
- **Card White** (`#ffffff`): light-mode card/entry background, and the fixed plate behind the sidebar octopus mark in both themes (so the purple mark reads consistently against either page ground).
- **Ink** (`#06171f`): text-on-teal color for tag pills and the dark-mode accent-text color, chosen for contrast rather than as a decorative near-black.

### Named Rules
**The One Saturated Moment Rule.** Only the hero renders on the full purple-to-navy gradient. It is fixed regardless of site theme; every other surface (cards, feed, sidebar) uses the light/dark token pairs and never the raw gradient.

**The Single-Teal Tag Rule.** Every category and tag pill sitewide is teal (`#4faab3` background, `#06171f` text), overriding the theme's default per-term color rotation. One color per taxonomy element, no exceptions.

## Typography

**Display/Headline Font:** Etna Sans Serif (with system sans-serif fallback via `--base-font-family`)
**Body Font:** Garet (with system sans-serif fallback)
**Label/Mono Font:** the theme's existing code font (`--code-font-family`), reused for date tags

**Character:** Etna is the confident, geometric voice for anything that names an entry — its weight range (400–800) is loaded but only the 700 weight is currently in use. Garet is the rounder, quieter voice for body text and excerpts, keeping long-form reading calm against Etna's punch in headlines.

### Hierarchy
- **Headline** (700, 3rem, scaling to 3.6rem at the `xl` breakpoint, line-height 1.2): the hero's entry title, in Etna.
- **Title** (700, 2rem, scaling to 2.2rem at `xl`, line-height 1.3): each feed entry's title, in Etna.
- **Body** (400, 1.5rem, line-height 1.6, max-width 70ch): entry excerpts; the hero excerpt runs slightly larger at 1.7rem, max-width 65ch.
- **Label** (700, 1.3rem, tabular numerals): the date tag, set in the code font family for a log-timestamp feel, not Etna or Garet.

### Named Rules
**The Etna-Names-It Rule.** Etna is reserved for anything that identifies an entry (hero title, entry title). Garet carries everything that describes it (excerpts, footers). Neither font substitutes for the other's role.

## Layout

The homepage is a single fixed-sidebar / scrolling-feed layout inherited from the theme's two-column shell, but the main pane's internal structure is bespoke: a `.changelog` flex column (`gap: var(--section-separation)`) that renders exactly one `changelog-hero` first, followed by a `changelog-wave-divider`, then a run of `changelog-entry` cards for every subsequent post, paginated by the theme's existing pagination partial. The hero switches to a two-column grid (`1.3fr` content / `1fr` image, `gap: 30px`) only at the `md` breakpoint and only when the entry has a cover image; below `md` and for image-less entries it stacks as a single column. The wave divider is 32px tall by default and grows to 48px at `md`, overlapping the hero slightly (`margin-top: calc(var(--section-separation) * -0.6)`) so it reads as a waterline rather than a gap.

## Elevation & Depth

The system is a hybrid: flat color blocks for the ground and hero, with the theme's existing two-step ambient shadow scale (`--shadow-l1` at rest, `--shadow-l2` on hover/emphasis) doing the lifting for cards. Entry cards and the hero image sit at `--shadow-l1`; the hero itself and any hovered entry card promote to `--shadow-l2`. Hover on a `changelog-entry` also lifts it 2px (`translateY(-2px)`), paired with the shadow change, over a 0.3s ease transition.

### Named Rules
**The Hover-Lifts Rule.** Interactive cards (`changelog-entry`) respond to hover with both a shadow promotion (`l1` → `l2`) and a 2px upward translation together, never one without the other.

## Shapes

Two radius steps cover the system: a 14px card radius (`--card-border-radius`) shared by entry cards, the hero, and the hero's cover image, and a 6px pill radius (`--tag-border-radius`) shared by every date tag and category/tag pill. There is no third radius step and no sharp-corner surface in the changelog system.

## Components

### Chips (Date Tags and Category Pills)
- **Date tag (`changelog-tag`):** solid fill in the theme's acting accent color (purple in light mode, teal in dark mode; fixed teal-on-navy inside the hero), white/ink text depending on contrast, 6px radius, tabular-numeral date format (`2026.07.27`), set in the code font.
- **Category pill (`changelog-categories a`):** low-opacity teal fill at rest (`rgba(79,170,179,0.15)` light / `0.22` dark) with a darker teal-tinted text color, brightening to a stronger teal opacity on hover (`0.28` light / `0.34` dark) over a 0.3s color transition. Inside the hero, pills switch to solid light-blue-on-navy at rest and solid teal-on-ink on hover, since the hero's fixed gradient can't use the theme-dependent low-opacity tokens.

### Cards / Containers
- **Corner Style:** 14px radius, matching the hero and hero image.
- **Background:** solid white (light) / navy-tinted `#17306a` (dark) for entries; the fixed purple-to-navy gradient for the hero, regardless of theme.
- **Shadow Strategy:** `--shadow-l1` at rest, `--shadow-l2` on hover (entries) or permanently (hero). See Elevation & Depth.
- **Border:** none; separation comes from background contrast and shadow, not strokes.
- **Internal Padding:** `var(--card-padding)` for entries; `calc(var(--card-padding) * 1.4)` for the hero, the one place padding scales up.

### Navigation (Sidebar)
- Fixed sidebar carries the octopus mark badge, name, subtitle ("Database Engineer with a Passion for Automation"), and social links; the mark sits on a constant white plate (`padding: 10%`, `background-color: #ffffff`) regardless of theme so the purple ink reads the same against light water-tint and dark navy grounds alike. No emoji icon is used (the legacy 🦄 sidebar icon has been removed).

### Wave Divider (signature component)
A single real Brand Kit wave-art image (`/img/wave-divider.png`), not a CSS rule or gradient fade, spans full width between the hero and the feed at 32px height (48px at `md`), rendered at reduced opacity in dark mode (0.55 vs 0.9 light) so it doesn't overpower the navy ground. It appears exactly once per homepage load, directly beneath the hero.

## Do's and Don'ts

### Do:
- **Do** treat the four brand colors (purple, navy, light-blue, teal) as named, assigned roles — never introduce a fifth accent hue into the changelog system.
- **Do** keep the hero on the fixed purple-to-navy gradient in both themes; it is the system's one deliberately saturated surface.
- **Do** set every category/tag pill sitewide in teal, overriding the theme's default per-term color rotation.
- **Do** use Etna for anything that names an entry and Garet for anything that describes it.
- **Do** preserve real tag/category casing as written (`capitalizeListTitles = false`) — this is a deliberate site behavior reflecting real-world tool names like "dbatools", not a bug to fix.
- **Do** pair a shadow promotion with a translateY lift on hover for interactive cards; never apply one without the other.

### Don't:
- **Don't** ban gradients as a device — the world's own hero relies on one; the prohibition that matters is scope (hero only), not gradients themselves.
- **Don't** add a third card-radius step or a sharp-cornered surface; the system uses exactly two radii (14px card, 6px pill).
- **Don't** treat the single-post article page, archives page, search page, or the Buy the Book / Finding Data Friends pages as redesigned. They currently inherit the global color and font tokens from `custom.scss` but their structure and composition have not been reviewed against this system yet.
- **Don't** record CC BY-NC-SA 4.0 as the project's code license — it is the deliberately-retained *content* license (`article.license.default` in `params.toml`); the separate root `LICENSE` file covers code under MIT.
