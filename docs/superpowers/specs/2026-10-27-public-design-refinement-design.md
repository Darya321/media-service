# Public design refinement

## Intent

Bring the public site back to the restrained visual language of the approved “original” concept: a precise grid, calm typography, clear hierarchy, and purposeful lime/forest accents. The result must look intentionally art-directed rather than assembled from oversized cards and unrelated type scales.

## Goals

- Use Helvetica Neue with conservative fallbacks throughout the product.
- Give public headings, body copy, labels, and controls a consistent type scale and mostly regular/medium weights.
- Prevent awkward Russian line endings and remove the broken article drop cap.
- Make the homepage “УПАКОВАНО” wordmark span the viewport while keeping the Figma island artwork at or below its native display size.
- Turn `/about` into a presentational explanation of the project, its audience, four-part product model, and educational limitations.
- Make the media filter compact and professional, and preserve the catalogue position after filtering or searching.
- Do not upscale low-resolution raster assets on Media. Use crisp CSS/typographic covers there instead.

## Non-goals

- No change to the Rails data model, admin workflows, calculator behavior, or supplier filtering.
- No analytics or view counters.
- No new generated imagery.
- No attempt to redesign the admin interface beyond inheriting the Helvetica Neue font stack.

## Constraints

- Preserve the existing original baseline at commit `65d4451`.
- Keep the current Figma-derived palette, grid background, routes, and server-side media filters.
- Public layouts must remain usable at desktop, tablet, and 375px mobile widths.
- Existing accessibility names, focus states, and semantic landmarks remain intact.

## Approaches considered

1. **Page-by-page CSS patches.** Fast, but it would preserve the inconsistent scale and produce more one-off exceptions. Rejected.
2. **Replace all imagery with newly generated photographs.** Could provide larger files, but conflicts with the user’s request to avoid an AI-generated feel and introduces an inconsistent art direction. Rejected.
3. **System-first refinement with crisp editorial graphics.** Normalize global type tokens and wrapping, then rebuild the affected public compositions around the existing grid and Figma palette. Media uses CSS/typographic covers instead of weak raster files. Selected because it best matches the approved original and addresses the cause rather than the screenshot alone.

## Design decisions

- Font stack: `"Helvetica Neue", Helvetica, Arial, sans-serif`.
- Public body text uses 400; navigation, controls, and labels use 500; display headings use 500–600 only where contrast is needed.
- Headings use balanced wrapping and paragraphs use pretty wrapping. A small global typography controller binds one- and two-letter Russian short words to the following word with a non-breaking space while excluding form fields and code-like content.
- Homepage wordmark is full-bleed and sized from the viewport, not the content container.
- Article body copy has no decorative first-letter treatment.
- About page is an editorial composition: proposition, four product capabilities, two audiences, educational transparency, and clear next actions.
- Media filter links and search form target `#media-catalog`; the catalogue owns a scroll margin beneath the sticky visual header area.
- Media hero, cards, and promotion use flat color fields, typography, borders, and category-specific tones. They contain no raster `<img>` elements.

## Success criteria

- No word is visually damaged by the article opening treatment.
- The homepage wordmark reads as the dominant full-width element on desktop and remains contained on mobile.
- Media filter/search URLs include the catalogue fragment and land at the filter/results area.
- About page explains what the service does, who it serves, and what is educational/demo content.
- Media contains no upscaled low-resolution raster images.
- All automated tests, responsive checks, style checks, and security checks pass.
