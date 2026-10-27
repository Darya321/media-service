# Public Design Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the public site into the restrained, professional “original” design language with consistent Helvetica Neue typography, a presentation-ready About page, and a stable professional Media catalogue.

**Architecture:** Establish one typography foundation in design tokens, base CSS, and a small Stimulus controller; public page styles then consume that foundation. Media keeps its server-side search/filtering but uses anchored navigation and code-native editorial covers instead of low-resolution raster imagery.

**Tech Stack:** Ruby on Rails 8.1, ERB, Propshaft CSS, Stimulus, Minitest/Capybara.

**Spec:** `docs/superpowers/specs/2026-10-27-public-design-refinement-design.md`

## Global Constraints

- Preserve the original baseline at commit `65d4451` and do not push without explicit permission.
- Use `"Helvetica Neue", Helvetica, Arial, sans-serif`; no web-font download.
- No new generated imagery and no raster `<img>` elements in Media hero/cards/promotion.
- No data model, admin workflow, calculator, supplier-filtering, analytics, or counter changes.
- Keep public pages usable at desktop, tablet, and 375px widths.

## Review Focus

- Text inside buttons, form controls, code/preformatted blocks, and user-entered fields must not be mutated by short-word handling; cover in the typography system test.
- Media search and every category link must preserve `#media-catalog`; cover in controller and media system tests.
- Unknown-category and empty-search states must still render in the anchored catalogue; cover in the existing posts controller tests.
- Media covers must remain meaningful without images and expose readable category/title text; cover in controller tests.
- The viewport wordmark must not create horizontal overflow at 375px; cover in responsive CSS checks and browser QA.

---

### Task 1: Typography foundation and homepage wordmark

**Files:**
- Modify: `app/assets/stylesheets/design_tokens.css`
- Modify: `app/assets/stylesheets/application.css`
- Modify: `app/assets/stylesheets/components.css`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `app/views/layouts/application.html.erb`
- Modify: `app/views/home/_hero.html.erb`
- Create: `app/javascript/controllers/typography_controller.js`
- Test: `test/system/responsive_layout_test.rb`
- Test: `test/system/homepage_flow_test.rb`

**Interfaces:**
- Produces: global public type tokens, `[data-controller~="typography"]`, `.hero-shell__wordmark`, and Russian short-word non-breaking behavior consumed by all later tasks.

- [ ] **Step 1: Write failing typography and wordmark tests**

Assert the token file contains the exact Helvetica Neue stack and no Arimo, the application layout attaches the typography controller, the homepage contains a full-bleed wordmark hook, and the public CSS no longer contains the article `::first-letter` rule.

- [ ] **Step 2: Run the focused tests and confirm failure**

Run: `bin/rails test test/system/homepage_flow_test.rb test/system/responsive_layout_test.rb`

- [ ] **Step 3: Implement the typography foundation**

Use regular/medium defaults, balanced headings, pretty paragraphs, a safe Stimulus text-node walker for one/two-letter Russian words, a viewport-width homepage wordmark, and remove the publication drop cap.

- [ ] **Step 4: Run the focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `style: refine public typography`

### Task 2: Presentation-ready About page

**Files:**
- Modify: `app/views/pages/about.html.erb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `test/controllers/pages_controller_test.rb`
- Modify: `test/system/navigation_test.rb`

**Interfaces:**
- Consumes: typography foundation from Task 1.
- Produces: `.about-page`, `.about-capabilities`, `.about-audiences`, and `#manufacturers` retained for the homepage deep link.

- [ ] **Step 1: Write failing About structure tests**

Assert a clear value proposition, four capability items, business/manufacturer audience sections, educational limitation copy, calculator CTA, and retained `#manufacturers` target.

- [ ] **Step 2: Run the focused tests and confirm failure**

Run: `bin/rails test test/controllers/pages_controller_test.rb test/system/navigation_test.rb`

- [ ] **Step 3: Build the editorial About composition**

Use the original grid/palette, restrained borders, numbered capability rows, two audience panels, and concise copy without raster images.

- [ ] **Step 4: Run the focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `feat: present the project story`

### Task 3: Professional anchored Media catalogue

**Files:**
- Modify: `app/views/posts/index.html.erb`
- Modify: `app/views/posts/_media_feature.html.erb`
- Modify: `app/views/posts/_media_card.html.erb`
- Modify: `app/views/posts/_media_promotion.html.erb`
- Modify: `app/views/posts/_post.html.erb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `test/controllers/posts_controller_test.rb`
- Modify: `test/system/media_flow_test.rb`

**Interfaces:**
- Consumes: existing `q`, `category`, `@hero_post`, section collections, and placement helpers.
- Produces: `#media-catalog`, anchored filter/search URLs, and raster-free `.media-visual` variants keyed by category.

- [ ] **Step 1: Write failing Media behavior and markup tests**

Assert category links and search form include the `media-catalog` fragment, Media hero/cards/promotion contain no image elements, category/title text remains present, and the system journey retains the fragment after search/filter actions.

- [ ] **Step 2: Run the focused tests and confirm failure**

Run: `bin/rails test test/controllers/posts_controller_test.rb test/system/media_flow_test.rb`

- [ ] **Step 3: Refine the Media toolbar and editorial visuals**

Add the anchored catalogue, restrained rectangular filter controls, compact search, scroll margin, and CSS/typographic category covers. Preserve query/category combinations and partner/external labels.

- [ ] **Step 4: Run the focused tests and confirm green**

Run the command from Step 2; expected 0 failures and 0 errors.

- [ ] **Step 5: Commit**

Commit message: `style: professionalize media catalogue`

### Task 4: Whole-site verification and visual QA

**Files:**
- Modify only files required by verified responsive or accessibility regressions.

**Interfaces:**
- Consumes: completed Tasks 1–3.
- Produces: verified public layouts at desktop, 768px, and 375px.

- [ ] **Step 1: Run all automated tests**

Run: `bin/rails test` and `bin/rails test:system`; expected 0 failures and 0 errors.

- [ ] **Step 2: Run code/style/security checks**

Run: `bin/rubocop`, `bundle exec brakeman --no-pager`, and `bin/bundler-audit check`; expected no offenses, warnings, or vulnerabilities.

- [ ] **Step 3: Inspect `/`, `/about`, `/media`, a filtered Media result, and a publication at desktop, 768px, and 375px**

Confirm no horizontal overflow, no pixelated Media imagery, balanced hierarchy, intact focus/labels, and anchored filter behavior.

- [ ] **Step 4: Fix only verified regressions and rerun their focused tests**

- [ ] **Step 5: Commit**

Commit message: `test: verify public design refinement`
