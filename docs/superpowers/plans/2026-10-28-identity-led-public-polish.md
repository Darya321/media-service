# Identity-led Public Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the approved identity-led direction across the brand assets, homepage hero and calculator, editorial cards, Materials, About, and Media while adding a separate branded holding page.

**Architecture:** Package the confirmed Gerhaus face and exact supplied logo as project assets, then expose small view/helper interfaces for identity imagery and generated editorial covers. Keep calculator data and Media data server-driven; the new visualizations are semantic HTML/CSS layers over existing values rather than new business logic.

**Tech Stack:** Ruby on Rails 8.1, ERB, Propshaft CSS, Stimulus, Minitest/Capybara, built-in image generation.

**Spec:** `docs/superpowers/specs/2026-10-28-identity-led-public-polish-design.md`

**Handoff status (2026-10-28):** Tasks 1–3 are implemented in commits `60f9b3a`, `dfcd770`, and `f1f09a7`. Resume at Task 4. The detailed continuation brief is `docs/HANDOFF-2026-10-28.md`; the unchecked boxes below are the original execution checklist, not a claim that completed Tasks must be repeated.

## Global Constraints

- `/soon` is a separate route and must not replace `/`.
- Use packaged Gerhaus Regular only for identity display text; keep Helvetica Neue everywhere else.
- Use the supplied logo without redrawing it; derive the favicon from its leaf mark.
- Do not display the 546 px packaging island above its native width.
- Generated editorial images contain no text, logos, or watermarks.
- Do not change calculator formulas, submissions, supplier filtering, admin workflows, analytics, or counters.
- Preserve accessible names, keyboard navigation, reduced-motion behavior, and current public routes.

## Review Focus

- A missing local/system font must still render a readable Helvetica fallback; verify the packaged font request and computed family in browser QA.
- Logo imagery must retain useful accessible text in the header while decorative holding-page usage stays hidden; cover in navigation and Pages controller tests.
- The `ё/Ё` normalization must not mutate inputs, selects, textareas, code, or contenteditable content; cover in JavaScript behavior tests.
- Generated Media covers must map safely for publication kinds outside the three dedicated visuals; cover the helper fallback in tests.
- Layered hero and Media compositions must not overflow at the 900/560 px breakpoints; include 901, 768, and 375 px browser checks.

---

### Task 1: Package the identity and add the holding page

**Files:**
- Create: `app/assets/fonts/gerhaus-regular.otf`
- Create: `app/assets/images/brand/upakovano-wordmark.png`
- Create: `app/assets/images/brand/upakovano-leaf.png`
- Modify: `app/assets/stylesheets/design_tokens.css`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/views/shared/_header.html.erb`
- Modify: `app/views/layouts/application.html.erb`
- Create: `app/views/layouts/holding.html.erb`
- Create: `app/views/pages/soon.html.erb`
- Modify: `app/controllers/pages_controller.rb`
- Modify: `config/routes.rb`
- Modify: `test/controllers/pages_controller_test.rb`
- Modify: `test/system/navigation_test.rb`

**Interfaces:**
- Produces: `--font-identity`, `.brand__logo`, route helper `soon_path`, and exact brand assets consumed by the remaining tasks.

- [ ] **Step 1: Write failing identity and holding-page tests**

Assert `soon_path` responds successfully with the dedicated holding layout, full logo, heading, island, and root CTA. Assert the public header has an image logo with the existing accessible home label and the application layout points favicon/touch links at the leaf asset.

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `bin/rails test test/controllers/pages_controller_test.rb test/system/navigation_test.rb`

- [ ] **Step 3: Add exact assets and implement the route/layout**

Copy `Gerhaus-Regular.otf` and the supplied transparent wordmark into the named paths. Crop the leaf mark exactly into a square transparent PNG. Add `@font-face`, the header image, favicon links, `/soon`, its standalone layout, and responsive holding-page CSS.

- [ ] **Step 4: Run focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `feat: add portable brand identity and holding page`

### Task 2: Reconstruct the homepage hero and calculator result

**Files:**
- Modify: `app/views/home/_hero.html.erb`
- Modify: `app/views/home/_calculator.html.erb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `test/controllers/home_controller_test.rb`
- Modify: `test/system/homepage_flow_test.rb`

**Interfaces:**
- Consumes: `--font-identity` and the existing island asset.
- Produces: `.hero-shell__stage`, `.identity-wordmark`, and semantic `.price-chart` markup using the existing reference result and calculator values.

- [ ] **Step 1: Write failing homepage composition tests**

Assert the hero stage contains the identity wordmark before the island layer and the island retains explicit intrinsic dimensions. Assert the calculator result contains five bars, an active quantity marker, material/region metadata, the reference price, and its existing disclaimer.

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `bin/rails test test/controllers/home_controller_test.rb test/system/homepage_flow_test.rb`

- [ ] **Step 3: Implement the layered mockup and crisp calculator visualization**

Rebuild the desktop stage with the wordmark behind the centered island and copy at lower left. Add an accessible CSS chart and metadata without changing form fields, result calculation, or submission URL. Add tablet/mobile reflow rules.

- [ ] **Step 4: Run focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `style: match the identity-led homepage mockup`

### Task 3: Generate and integrate editorial Media covers

**Files:**
- Create: `app/assets/images/editorial/media-material-guide-v2.png`
- Create: `app/assets/images/editorial/media-cardboard-review-v2.png`
- Create: `app/assets/images/editorial/media-maker-story-v2.png`
- Modify: `app/helpers/application_helper.rb`
- Modify: `app/views/home/_media.html.erb`
- Modify: `app/assets/stylesheets/public.css`
- Create: `test/helpers/application_helper_test.rb`
- Modify: `test/controllers/home_controller_test.rb`

**Interfaces:**
- Produces: `home_media_asset(post)` returning a generated logical asset path by publication kind with a deterministic fallback.

- [ ] **Step 1: Write failing asset-mapping and markup tests**

Assert guide, review, and interview kinds map to the expected logical paths, other approved kinds use the material-guide fallback, and the homepage renders three image covers with article-specific alt text.

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `bin/rails test test/helpers/application_helper_test.rb test/controllers/home_controller_test.rb`

- [ ] **Step 3: Generate three final landscape assets**

Use one built-in image-generation call per asset with the shared art direction from the spec. Inspect each output, copy the selected files into the exact project paths, and keep the files at a size suitable for sharp 1.5:1 card crops.

- [ ] **Step 4: Integrate responsive images and styling**

Add `home_media_asset(post)`, render `image_tag` in the existing cards, and use `object-fit: cover` with consistent borders/radii. Keep all textual article metadata as HTML.

- [ ] **Step 5: Run focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 6: Commit**

Commit message: `feat: add editorial homepage media imagery`

### Task 4: Normalize language and tighten Materials and About

**Files:**
- Modify: `app/javascript/controllers/typography_rules.js`
- Modify: `app/javascript/controllers/typography_controller.js`
- Modify: `test/javascript/typography_rules_test.mjs`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `test/controllers/materials_controller_test.rb`
- Modify: `test/controllers/pages_controller_test.rb`

**Interfaces:**
- Produces: `normalizeRussianYo(text)` composed with short-word binding for visible text nodes.

- [ ] **Step 1: Write failing normalization and structural regression tests**

Test both lowercase and uppercase normalization, unchanged ordinary text, and the existing skip-selector contract. Assert Materials cards retain scores/actions and About retains every required section.

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `node --test test/javascript/typography_rules_test.mjs` and `bin/rails test test/controllers/materials_controller_test.rb test/controllers/pages_controller_test.rb`.

- [ ] **Step 3: Implement safe text normalization and compact page scales**

Normalize public text nodes before binding short words, preserve skipped nodes, remove the fixed Materials card minimum height/auto spacer, and reduce About’s largest display maxima by 12–18%.

- [ ] **Step 4: Run focused tests and confirm green**

Run the commands from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `style: tighten public content rhythm`

### Task 5: Recompose the Media hero in the project identity

**Files:**
- Modify: `app/views/posts/_media_feature.html.erb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `test/controllers/posts_controller_test.rb`
- Modify: `test/system/media_flow_test.rb`

**Interfaces:**
- Consumes: `--font-identity` and the existing hero post/category/placement helpers.
- Produces: `.media-hero__display`, `.media-hero__panel`, and `.media-hero__article` as one layered, raster-free composition.

- [ ] **Step 1: Write failing Media-hero tests**

Assert the feature keeps its post/category/placement content, contains the new layered hooks and article link, contains no image element, and still exposes the main call to action.

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `bin/rails test test/controllers/posts_controller_test.rb test/system/media_flow_test.rb`

- [ ] **Step 3: Implement the identity-led layered hero**

Replace the split empty field with a cream grid stage, forest structural panel, low-contrast Gerhaus `МЕДИА`, lime index, and overlapping article card. Preserve accessible reading order and create explicit tablet/mobile stacking rules.

- [ ] **Step 4: Run focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `style: recompose the media hero`

### Task 6: Whole-site visual and automated verification

**Files:**
- Modify only files required by verified regressions.

**Interfaces:**
- Consumes: completed Tasks 1–5.
- Produces: verified layouts at 1440, 901, 768, and 375 px.

- [ ] **Step 1: Run complete automated verification**

Run: `bin/rails test`, `bin/rails test:system`, `node --test test/javascript/typography_rules_test.mjs`, `bin/rubocop`, `bundle exec brakeman --no-pager`, and `bin/bundler-audit check`.

- [ ] **Step 2: Inspect required routes in a real browser**

Inspect `/`, `/soon`, `/about`, `/materials`, `/media`, a filtered Media result, and a publication at 1440, 901, 768, and 375 px. Confirm no horizontal overflow, exact logo/favicon loading, correct Gerhaus/Helvetica separation, sharp generated images, native-size island, and working filter anchoring.

- [ ] **Step 3: Fix only verified regressions and rerun affected checks**

- [ ] **Step 4: Commit**

Commit message: `test: verify identity-led public polish`
