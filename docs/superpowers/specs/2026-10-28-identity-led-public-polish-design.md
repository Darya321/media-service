# Identity-led public polish

## Intent

Bring the public site closer to the approved mockup while keeping the restrained system established in the previous refinement. The result should feel authored: the Gerhaus wordmark and packaging island define the first screen, Helvetica Neue carries the interface, data-heavy areas look purposeful, and editorial imagery replaces empty color fields.

## Chosen approach

The selected direction is **identity plus technology**. It combines a literal reconstruction of the homepage mockup with code-native calculator graphics, a stronger identity-led Media hero, and a small set of high-quality generated editorial images. A separate branded holding page is added without replacing the working homepage.

Alternatives considered:

- A photo-forward redesign across calculator and Media was rejected because it would weaken the strict grid and move away from the mockup.
- A purely literal patch of the marked screenshots was rejected because it would leave the calculator and Media compositions visually unresolved.

## Goals

- Add the supplied full wordmark logo to the site header and branded holding page.
- Derive the favicon and touch icon from the supplied two-leaf mark without redrawing the logo.
- Add a separate `/soon` holding page; the existing homepage remains the root route.
- Reconstruct the first homepage screen to match the mockup: the Gerhaus `УПАКОВАНО` sits behind the packaging island, supporting copy stays at the lower left, and the three tool cards begin immediately below.
- Use Gerhaus only for the large identity wordmark. Helvetica Neue remains the interface and editorial font.
- Turn the `24 ₽` result panel into a clearly recognizable calculator visualization with a quantity axis, bars, active value, compact calculation metadata, and no decorative raster artwork.
- Replace the three empty homepage Media covers with three cohesive high-resolution editorial images generated specifically for the articles.
- Remove `ё` and `Ё` from visible public text while leaving form values and stored user-entered content untouched.
- Reduce excess vertical space between material summaries, scores, and actions.
- Reduce the largest About-page headings while preserving hierarchy.
- Replace the current split Media hero with a more creative identity-led composition using the grid, forest, lime, Gerhaus display typography, and layered article information.

## Assets

- Source logo: the user-supplied transparent PNG. The full wordmark is used in the header and holding page.
- Favicon: an exact crop of the two-leaf mark from the source logo, exported as square PNG and SVG-compatible browser artwork where practical.
- Packaging island: retain the current transparent Figma asset and do not render it above its native 546 px width.
- Gerhaus: copy the user-provided locally installed `Gerhaus-Regular.otf` into the project, expose it through `@font-face`, and fall back to Helvetica Neue. The user confirmed that the font may be used in commercial and non-commercial work, so the repository remains visually portable.
- Editorial images: generate three landscape images with one shared art direction — high-end packaging editorial photography, natural material texture, warm neutral light, forest/lime accents only where plausible, no text, no logos, no watermark, and enough negative space for card cropping.

## Page compositions

### Header and holding page

The header uses the supplied wordmark at a compact readable size instead of a text-only brand. `/soon` is a complete standalone branded page with the logo, `Скоро здесь будет «Упаковано»`, a short explanation, the packaging island, and a link back to the working project. It uses the standard grid background and does not replace `/`.

### Homepage hero

On desktop, the hero is a single layered canvas. The full-width Gerhaus wordmark is the rear layer. The island sits above its center/lower portion, covering the letters as in the mockup. The value proposition sits lower left. Tool cards start at the bottom edge of the composition. On tablet and mobile, the layers remain intentional but reflow without horizontal overflow or unreadable overlap.

### Calculator result

The result keeps the current calculated unit price and disclaimer. It adds a horizontal set of quantity labels and five vertical comparison bars; the selected quantity and price use lime. A small metadata row identifies material and region from the current form values. All graphics are HTML/CSS so they stay crisp and accessible.

### Homepage Media cards

Each card receives a generated image mapped by article slug. Images use responsive `image_tag` markup, cover cropping, meaningful alt text, and consistent aspect ratio. The title, type, and summary remain selectable HTML below the image.

### Materials

Cards no longer use a fixed 44 rem minimum height. Scores follow the description with a compact top margin, and the action remains aligned across the row through normal flex layout rather than a large empty spacer.

### About

Reduce the hero, manifesto, capability heading, and audience heading maximum sizes by roughly 12–18%. Keep the existing grid, content, and section order.

### Media hero

Use one unified cream/grid canvas instead of two disconnected halves. A dark-green structural panel, large low-contrast Gerhaus `МЕДИА`, lime index marker, article card, and compact category metadata overlap deliberately. The hero contains no low-resolution image and remains readable at 375 px.

## Typography and language

- Helvetica Neue remains the global stack.
- Gerhaus is restricted to `.identity-wordmark` and Media’s background display word.
- The typography controller converts Cyrillic `ё/Ё` to `е/Е` in visible public text nodes and continues binding short Russian words. It skips inputs, textareas, options, code, preformatted content, contenteditable regions, and explicitly opted-out elements.
- Source copy introduced in this change is written without `ё`.

## Constraints and non-goals

- Do not change calculator formulas, submission behavior, supplier filtering, admin workflows, analytics, or counters.
- Do not replace the working homepage with the holding page.
- Package only the confirmed Gerhaus Regular face; do not extend it to interface text or synthesize additional weights.
- Do not upscale the packaging island beyond its native width.
- Do not use generated text inside editorial images.
- Preserve keyboard navigation, accessible names, reduced-motion behavior, and all current routes.

## Success criteria

- The desktop hero matches the supplied mockup’s layering and visual proportions, including the wordmark behind the island.
- The supplied logo appears in the header and `/soon`; the browser tab uses the leaf favicon.
- Calculator and Media blocks no longer read as empty placeholders.
- Three homepage Media cards render sharp, coherent images without text artifacts.
- No visible public copy contains `ё` or `Ё` after the typography controller runs.
- Materials cards are visibly shorter while their actions align.
- About headings remain prominent but no longer dominate the viewport.
- Homepage, `/soon`, `/about`, `/materials`, `/media`, and a publication have no horizontal overflow at 1440, 768, and 375 px.
