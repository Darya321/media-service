# Упаковано MVP Implementation Plan

> **For agentic workers:** выполнять задачи строго по порядку, применяя TDD и делая указанный локальный Git-коммит после зелёных проверок каждой задачи. Не отправлять изменения в GitHub без отдельного разрешения пользователя.

**Goal:** создать в существующем Rails-приложении рабочий учебный медиасервис «Упаковано»: публичный B2B-контент, демонстрационный калькулятор упаковки, каталог поставщиков, заявки, подписка и защищённая административная панель в визуальной системе утверждённого Figma-макета.

**Architecture:** монолит Ruby on Rails с серверным HTML на ERB, Turbo и небольшими Stimulus-контроллерами. Контент и заявки хранятся в SQLite; публичные контроллеры читают только опубликованные и активные записи; административные контроллеры наследуются от защищённого `Admin::BaseController`. Формула расчёта живёт в чистом Ruby-сервисе `PackagingEstimator`, вызывается через внутренний JSON endpoint и не зависит от DOM или внешнего API.

**Tech Stack:** Ruby 4.0.6, Rails 8.1.4, SQLite, ERB, Propshaft, Importmap, Turbo, Stimulus, Minitest, Capybara, Selenium, BCrypt.

**Spec:** `docs/superpowers/specs/2026-10-27-upakovano-mvp-design.md`

## Global Constraints

- Не пересоздавать Rails-приложение и не менять утверждённый стек.
- Не добавлять React, Vue, Tailwind, Action Text, Active Storage или готовую admin-панель.
- Сначала писать падающий тест, затем минимальную реализацию и только потом рефакторинг.
- Не хранить пароли, реальные персональные данные или временные Figma URL в Git.
- Все Figma-ассеты сохранять локально в `app/assets/images/figma/` с понятными именами.
- Контентные сущности рендерить из базы; ERB не должен содержать демонстрационные массивы записей.
- Публичный интерфейс не показывает черновики, будущие публикации и неактивных поставщиков.
- Расчёт всегда обозначать как предварительный, а заявку — как учебную, не отправленную реальному поставщику.
- Проверять ширины 1440, 1024, 768 и 375 px; на 375 px не должно быть горизонтальной прокрутки.
- Каждый коммит локальный и тематический; не выполнять `git push`, не переписывать историю Git.

## Review Focus

Пять наиболее вероятных классов ошибок и тесты, которые должны их ловить:

1. **Некорректные числа калькулятора.** Нули, отрицательные значения, строки, чрезмерные размеры и тираж не должны приводить к `NaN`, `Infinity`, 500 или сохранению неверной заявки. Покрывается в задаче 7 unit- и request-тестами.
2. **Утечка непубличного контента.** Черновики, будущие публикации и неактивные поставщики не должны открываться прямой ссылкой или попадать в списки. Покрывается в задачах 8 и 9.
3. **Дубликаты email после нормализации.** Пробелы и разный регистр не должны создавать повторные подписки или администраторов. Покрывается в задачах 4, 11 и 12.
4. **Подмена связей в заявке.** Пользователь не должен адресовать заявку неактивному/несуществующему поставщику или передать произвольные рассчитанные суммы. Покрывается в задаче 8; суммы пересчитываются сервером.
5. **Неидемпотентные или небезопасные сиды.** Повторный запуск не увеличивает число стабильных записей, а отсутствие `ADMIN_EMAIL`/`ADMIN_PASSWORD` не создаёт администратора со слабым паролем. Покрывается в задаче 5.

## File and Responsibility Map

### Domain and services

| Path | Responsibility / public interface |
|---|---|
| `app/models/concerns/has_slug.rb` | Заполняет пустой `slug` из `slug_source`, возвращает `slug` из `to_param` |
| `app/models/category.rb` | Категория публикаций, `has_many :posts` |
| `app/models/post.rb` | Публикация; enum `kind`, enum `status`, scope `publicly_visible` |
| `app/models/material.rb` | Материал упаковки, оценки 1..5, `price_factor` |
| `app/models/supplier.rb` | Поставщик; enum `company_type`, scope `available`, сериализованные `regions`/`services` |
| `app/models/supplier_material.rb` | Уникальная связь поставщика и материала |
| `app/models/subscription.rb` | Нормализованный уникальный email |
| `app/models/inquiry.rb` | Параметры и серверный результат заявки; enum `status` |
| `app/models/admin.rb` | Нормализованный email и `has_secure_password` |
| `app/services/packaging_estimator.rb` | `.call(...) -> PackagingEstimator::Result`, чистая детерминированная формула |

### Public web interface

| Path | Responsibility |
|---|---|
| `config/routes.rb` | Публичные и admin routes, внутренний endpoint расчёта |
| `app/controllers/home_controller.rb` | Главная и отобранные DB-записи |
| `app/controllers/pages_controller.rb` | Страница `/about` |
| `app/controllers/posts_controller.rb` | `/media`, `/media/:slug`, только `publicly_visible` |
| `app/controllers/categories_controller.rb` | `/categories/:slug`, только публичные записи категории |
| `app/controllers/materials_controller.rb` | Список/карточка/фильтрация материалов |
| `app/controllers/calculator_controller.rb` | `show`, `estimate`; JSON строится только из `PackagingEstimator::Result` |
| `app/controllers/suppliers_controller.rb` | Список/карточка/фильтрация активных поставщиков |
| `app/controllers/subscriptions_controller.rb` | Создание подписки с Turbo/HTML обратной связью |
| `app/controllers/inquiries_controller.rb` | Новая и создание заявки с серверным пересчётом цены |
| `app/helpers/application_helper.rb` | Общие presentation helpers, активная навигация, формат оценок |
| `app/views/shared/` | Header, footer, flash, form errors, общие карточки |
| `app/javascript/controllers/menu_controller.js` | Доступное мобильное меню |
| `app/javascript/controllers/calculator_controller.js` | Сбор формы, запрос `/calculator/estimate`, рендер результата, синхронизация короткой/полной формы |
| `app/javascript/controllers/repeat_order_controller.js` | Подстановка фиксированного заказа и прокрутка к калькулятору |

### Admin interface

| Path | Responsibility |
|---|---|
| `app/controllers/admin/base_controller.rb` | `current_admin`, `require_admin`, общий layout |
| `app/controllers/admin/sessions_controller.rb` | Вход и выход, единственная точка без `require_admin` |
| `app/controllers/admin/dashboard_controller.rb` | Сводные счётчики и последние заявки |
| `app/controllers/admin/categories_controller.rb` | CRUD категорий |
| `app/controllers/admin/posts_controller.rb` | CRUD публикаций |
| `app/controllers/admin/materials_controller.rb` | CRUD материалов |
| `app/controllers/admin/suppliers_controller.rb` | CRUD поставщиков и их материалов |
| `app/controllers/admin/subscriptions_controller.rb` | Read-only список подписок |
| `app/controllers/admin/inquiries_controller.rb` | Список, карточка, изменение статуса |
| `app/views/layouts/admin.html.erb` | Изолированная оболочка admin-панели |

### Styles, assets, data and tests

| Path | Responsibility |
|---|---|
| `app/assets/stylesheets/application.css` | Порядок подключения stylesheet-файлов и минимальный reset |
| `app/assets/stylesheets/design_tokens.css` | Цвета, типографика, расстояния, радиусы, тени, container widths |
| `app/assets/stylesheets/components.css` | Кнопки, поля, карточки, chips, таблицы, notices |
| `app/assets/stylesheets/public.css` | Layout публичных страниц и Figma-секции |
| `app/assets/stylesheets/admin.css` | Admin layout и формы |
| `app/assets/stylesheets/responsive.css` | Контрольные media queries и reduced motion |
| `app/assets/images/figma/` | Локальные SVG/PNG, экспортированные из утверждённых Figma nodes |
| `db/seeds.rb` | Повторяемый демонстрационный набор и условный admin из ENV |
| `test/models/`, `test/services/` | Unit-тесты домена и формулы |
| `test/controllers/` | Request/controller-тесты routes, фильтров, auth и CRUD |
| `test/system/` | Сквозные публичные, admin и адаптивные сценарии |
| `README.md` | Запуск, admin, тесты, архитектура, caveats, сценарий защиты |

## Route Contract

План закрепляет следующие route helpers:

```ruby
root "home#show"
get "/about", to: "pages#about", as: :about
resources :posts, path: "media", param: :slug, only: %i[index show]
resources :categories, param: :slug, only: :show
resources :materials, param: :slug, only: %i[index show]
resource :calculator, only: :show, controller: "calculator" do
  post :estimate
end
resources :suppliers, param: :slug, only: %i[index show]
resources :subscriptions, only: :create
resources :inquiries, only: %i[new create]

namespace :admin do
  root "dashboard#show"
  resource :session, only: %i[new create destroy]
  resources :categories
  resources :posts
  resources :materials
  resources :suppliers
  resources :subscriptions, only: :index
  resources :inquiries, only: %i[index show update]
end
```

Expected public helpers: `root_path`, `about_path`, `posts_path`, `post_path(slug)`, `category_path(slug)`, `materials_path`, `material_path(slug)`, `calculator_path`, `estimate_calculator_path`, `suppliers_path`, `supplier_path(slug)`, `subscriptions_path`, `new_inquiry_path`, `inquiries_path`.

## Data Contract

- `Category`: `name:string`, `slug:string`, `description:text`.
- `Post`: `category:references`, `title:string`, `slug:string`, `summary:text`, `body:text`, `kind:integer`, `status:integer`, `published_at:datetime`, `featured:boolean`, `cover_asset:string`.
- `Material`: `name:string`, `slug:string`, `summary:text`, `description:text`, `use_cases:text`, four `*_score:integer`, `price_factor:decimal(6,3)`.
- `Supplier`: `name:string`, `slug:string`, `company_type:integer`, `specialization:string`, `description:text`, `minimum_order:integer`, `unit_price_from:decimal(10,2)`, `regions:text`, `services:text`, `contact_email:string`, `contact_url:string`, `promoted:boolean`, `active:boolean`.
- `SupplierMaterial`: `supplier:references`, `material:references` plus a unique composite index.
- `Subscription`: `email:string` plus unique index on normalized value.
- `Inquiry`: `supplier:references` optional, `material:references`, `email:string`, `product_type:string`, `length_mm:integer`, `width_mm:integer`, `height_mm:integer`, `weight_grams:integer`, `fragile:boolean`, `quantity:integer`, `budget:decimal(12,2)`, `deadline:date`, `region:string`, `print_option:string`, `extras:text`, `estimated_unit_price:decimal(10,2)`, `estimated_total_price:decimal(12,2)`, `estimated_low_price:decimal(12,2)`, `estimated_high_price:decimal(12,2)`, `status:integer`.
- `Admin`: `email:string`, `password_digest:string`, unique index on normalized email.

Serialized arrays use `serialize :regions, coder: JSON`, `serialize :services, coder: JSON`, and `serialize :extras, coder: JSON`; default is `[]`, not `nil`.

## Task 1: Establish the test baseline and secure-password dependency

**Files:**

- Modify: `Gemfile`
- Modify: `Gemfile.lock`
- Modify: `test/test_helper.rb`
- Create: `test/smoke/application_boot_test.rb`
- Create: `test/smoke/password_dependency_test.rb`

**Interfaces:** consumes current Rails skeleton; produces a booting test environment and available `BCrypt` for `has_secure_password`.

- [ ] Add a boot smoke test asserting `Rails.application` plus the expected Rails version; run it once to record the green pre-change baseline.
- [ ] Add a password dependency test that requires `bcrypt` and asserts `BCrypt::Password` is available; run it before changing the Gemfile and confirm the expected load failure.
- [ ] Uncomment `gem "bcrypt", "~> 3.1.7"`, run `bundle install`, and keep all existing dependency versions unless Bundler must resolve BCrypt.
- [ ] Set test execution to a deterministic order and keep Rails' default parallelization appropriate for SQLite.
- [ ] Run `bin/rails test test/smoke/application_boot_test.rb` and `bin/rails test`; require zero failures.
- [ ] Commit: `git add Gemfile Gemfile.lock test && git commit -m "test: establish Rails application baseline"`.

## Task 2: Add editorial models and stable slugs

**Files:**

- Create: `app/models/concerns/has_slug.rb`
- Create: `app/models/category.rb`
- Create: `app/models/post.rb`
- Create: `db/migrate/*_create_categories.rb`
- Create: `db/migrate/*_create_posts.rb`
- Create: `test/models/category_test.rb`
- Create: `test/models/post_test.rb`
- Create: `test/fixtures/categories.yml`
- Create: `test/fixtures/posts.yml`

**Interfaces:** `HasSlug#slug_source`, `HasSlug#to_param`; `Post.publicly_visible`; `Post.kinds`; `Post.statuses`.

- [ ] Write `CategoryTest` for required/unique name and slug, automatic slug, `to_param`, and dependent restriction when posts exist.
- [ ] Write `PostTest` for required fields, category association, all five kinds, draft/published states, and `publicly_visible` excluding draft and future-dated rows.
- [ ] Run `bin/rails test test/models/category_test.rb test/models/post_test.rb`; confirm failures because schema/classes are absent.
- [ ] Add migrations with non-null columns, sensible defaults, foreign key, unique indexes on both slug columns, and an index on `[status, published_at]`.
- [ ] Implement `HasSlug`: fill only a blank slug from `slug_source.parameterize`, never silently rename an existing URL, and return slug from `to_param`.
- [ ] Implement `Category` and `Post` validations/associations/enums. `Post.publicly_visible` means status published and `published_at` blank or not later than `Time.current`.
- [ ] Run migrations, then the two model tests and `bin/rails test`; require zero failures.
- [ ] Commit: `git add app/models db/migrate db/schema.rb test && git commit -m "feat: add editorial content models"`.

## Task 3: Add materials, suppliers, and their normalized relationship

**Files:**

- Create: `app/models/material.rb`
- Create: `app/models/supplier.rb`
- Create: `app/models/supplier_material.rb`
- Create: `db/migrate/*_create_materials.rb`
- Create: `db/migrate/*_create_suppliers.rb`
- Create: `db/migrate/*_create_supplier_materials.rb`
- Create: `test/models/material_test.rb`
- Create: `test/models/supplier_test.rb`
- Create: `test/models/supplier_material_test.rb`
- Create: `test/fixtures/materials.yml`
- Create: `test/fixtures/suppliers.yml`
- Create: `test/fixtures/supplier_materials.yml`

**Interfaces:** `Material#to_param`; `Supplier.available`; `Supplier#supports_region?(region)`; `Supplier#to_param`.

- [ ] Write failing tests for material slug uniqueness, four scores restricted to 1..5, and positive `price_factor`.
- [ ] Write failing tests for supplier company types, non-negative order/price, array serialization, `.available`, regional matching, and supplier/material associations.
- [ ] Write a failing test proving the join table rejects the same material twice for one supplier.
- [ ] Run the three test files and confirm missing-class/schema failures.
- [ ] Add migrations, including unique slugs and the composite unique index `[supplier_id, material_id]`; default `active` to true and boolean flags to false.
- [ ] Implement validations, `HasSlug`, enums, JSON serialization with `type: Array`, associations, scopes, and case-insensitive regional matching.
- [ ] Run model tests and the full suite; require zero failures.
- [ ] Commit: `git add app/models db/migrate db/schema.rb test && git commit -m "feat: add packaging marketplace models"`.

## Task 4: Add subscriptions, inquiries, and administrators

**Files:**

- Create: `app/models/subscription.rb`
- Create: `app/models/inquiry.rb`
- Create: `app/models/admin.rb`
- Create: `db/migrate/*_create_subscriptions.rb`
- Create: `db/migrate/*_create_inquiries.rb`
- Create: `db/migrate/*_create_admins.rb`
- Create: `test/models/subscription_test.rb`
- Create: `test/models/inquiry_test.rb`
- Create: `test/models/admin_test.rb`
- Create: `test/fixtures/subscriptions.yml`
- Create: `test/fixtures/inquiries.yml`
- Create: `test/fixtures/admins.yml`

**Interfaces:** normalized `Subscription#email`; `Inquiry.statuses`; `Inquiry#calculator_attributes`; `Admin#authenticate(password)`.

- [ ] Write failing subscription tests for format, whitespace trimming, lowercasing, case-insensitive uniqueness, and the unique DB index.
- [ ] Write failing inquiry tests for required email/material/product/dimensions/quantity/region, positive numeric bounds, optional supplier, JSON extras, and status enum.
- [ ] Write failing admin tests for normalized unique email, password length, secure digest, and authentication success/failure.
- [ ] Run these test files and confirm missing-class/schema failures.
- [ ] Add migrations with decimal precision from the Data Contract, foreign keys, enum defaults, and unique email indexes.
- [ ] Implement shared private email normalization only where needed; do not introduce a generalized concern unless both implementations are truly identical.
- [ ] Implement `Inquiry#calculator_attributes` returning the exact keyword hash accepted later by `PackagingEstimator.call`.
- [ ] Run model tests and the full suite; require zero failures.
- [ ] Commit: `git add app/models db/migrate db/schema.rb test && git commit -m "feat: add leads and admin accounts"`.

## Task 5: Create idempotent demonstration seeds

**Files:**

- Modify: `db/seeds.rb`
- Create: `test/integration/seeds_test.rb`

**Interfaces:** `bin/rails db:seed`; optional `ADMIN_EMAIL` and `ADMIN_PASSWORD`; stable slugs/emails are the upsert keys.

- [ ] Write a failing integration test for Review Focus #5 that loads seeds twice in an isolated test transaction and asserts unchanged counts for categories, posts, materials, suppliers, joins, subscriptions, and inquiries.
- [ ] Add a failing test that clears both admin ENV variables and proves no admin is created.
- [ ] Add a failing test that provides a valid email/password pair and proves exactly one normalized admin is created or updated.
- [ ] Run `bin/rails test test/integration/seeds_test.rb`; confirm failures against the empty seed file.
- [ ] Seed at least 4 categories, 6 materials, 6 suppliers of different types/regions, their joins, multiple published content kinds, one draft, one future publication, and safe fake leads.
- [ ] Use `find_or_initialize_by`/`find_or_create_by` plus `update!`; never rely on fixed integer IDs and never embed a plaintext admin password.
- [ ] Run the seed test, `RAILS_ENV=test bin/rails db:seed`, then the full suite; require zero failures.
- [ ] Commit: `git add db/seeds.rb test/integration/seeds_test.rb && git commit -m "feat: seed demonstration content safely"`.

## Task 6: Build routes, shared shell, design tokens, and Figma asset set

**Files:**

- Modify: `config/routes.rb`
- Modify: `app/views/layouts/application.html.erb`
- Modify: `app/helpers/application_helper.rb`
- Create: `app/controllers/home_controller.rb`
- Create: `app/controllers/pages_controller.rb`
- Create: `app/views/home/show.html.erb`
- Create: `app/views/pages/about.html.erb`
- Modify: `app/assets/stylesheets/application.css`
- Create: `app/assets/stylesheets/design_tokens.css`
- Create: `app/assets/stylesheets/components.css`
- Create: `app/assets/stylesheets/public.css`
- Create: `app/assets/stylesheets/responsive.css`
- Create: `app/views/shared/_header.html.erb`
- Create: `app/views/shared/_footer.html.erb`
- Create: `app/views/shared/_flash.html.erb`
- Create: `app/views/shared/_form_errors.html.erb`
- Create: `app/javascript/controllers/menu_controller.js`
- Create: `app/assets/images/figma/*`
- Create: `test/controllers/routes_test.rb`
- Create: `test/system/navigation_test.rb`

**Interfaces:** the Route Contract above; `nav_link_to(label, path)`; mobile menu targets `button` and `panel` with `toggle()`.

- [ ] Write a failing route test for every public/admin helper and a system test for desktop navigation plus keyboard-operable mobile menu.
- [ ] Run the two tests and confirm missing routes/elements.
- [ ] At implementation time invoke the `figma-design-to-code` skill before design-context tools; inspect nodes `206:1146`, `203:416`, `203:271`, `203:469`, and `203:522`.
- [ ] Export only used illustrations/icons to `app/assets/images/figma/`; record the source node in filenames or adjacent comments and verify no asset points to `figma.com` or a temporary CDN.
- [ ] Implement the Route Contract, minimal semantic `HomeController#show` and `PagesController#about` pages, Russian `<html lang="ru">`, title/viewport/CSRF tags, shared header/footer/flash, and the accessible `aria-expanded` menu.
- [ ] Define CSS variables for Figma colors (`#EEEDE9`, `#B9FF00`, dark green, muted green, beige), Arimo-first font stack, spacing, radii, borders, and max width; add visible focus and reduced-motion behavior.
- [ ] Run route/system tests and the full suite; require zero failures.
- [ ] Commit: `git add config app/assets app/controllers/home_controller.rb app/controllers/pages_controller.rb app/helpers app/javascript app/views/home app/views/pages app/views/layouts app/views/shared test && git commit -m "feat: establish public design system"`.

## Task 7: Implement the deterministic calculator end to end

**Files:**

- Create: `app/services/packaging_estimator.rb`
- Create: `app/controllers/calculator_controller.rb`
- Create: `app/views/calculator/show.html.erb`
- Create: `app/views/calculator/_form.html.erb`
- Create: `app/views/calculator/_result.html.erb`
- Create: `app/javascript/controllers/calculator_controller.js`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Create: `test/services/packaging_estimator_test.rb`
- Create: `test/controllers/calculator_controller_test.rb`
- Create: `test/system/calculator_flow_test.rb`

**Interfaces:**

```ruby
PackagingEstimator.call(
  product_type:, length_mm:, width_mm:, height_mm:, weight_grams:,
  fragile:, material:, quantity:, region:, print_option:, extras:
) # => PackagingEstimator::Result

PackagingEstimator::Result = Data.define(
  :unit_price, :total_price, :low_price, :high_price, :breakdown
)
```

`POST /calculator/estimate` returns JSON keys `unit_price`, `total_price`, `low_price`, `high_price`, `breakdown`, `disclaimer`; invalid parameters return status 422 and `errors`.

- [ ] Write a unit test for the mandatory reference: candles, 90×90×110 mm, microcorrugated board, quantity 500, Moscow, neutral optional fields produces exactly `24.00` per unit.
- [ ] Add unit tests for deterministic repeat calls, quantity discount direction, material factor, fragile/print/extras surcharge, Decimal-safe rounding, and Review Focus #1 invalid/zero/negative/extreme inputs.
- [ ] Write request tests for HTML show, valid JSON, 422 JSON, unknown material, and absence of persistence.
- [ ] Write a failing system test that changes fields, requests a calculation, displays unit/total/range/disclaimer, and links to filtered suppliers and inquiry.
- [ ] Run all three test files and confirm failures.
- [ ] Implement a pure service using `BigDecimal`; place validation bounds and coefficients as named constants. No controller params, view helpers, DB writes or external requests inside the service.
- [ ] Implement controller parameter coercion and rescue invalid input as 422, never 500; load `Material` server-side by slug and ignore any client-submitted `price_factor` or result amount.
- [ ] Implement the Figma-derived form/result and Stimulus fetch with CSRF token, busy state, inline errors, and progressive HTML fallback where the calculator page still explains the form if JS is unavailable.
- [ ] Run unit, controller, system and full tests; manually compare 1440 and 375 px with Figma calculator frame `203:416`.
- [ ] Commit: `git add app/services app/controllers/calculator_controller.rb app/views/calculator app/javascript/controllers/calculator_controller.js app/assets/stylesheets test && git commit -m "feat: add packaging cost calculator"`.

## Task 8: Implement suppliers, filtering, and safe inquiry creation

**Files:**

- Create: `app/controllers/suppliers_controller.rb`
- Create: `app/controllers/inquiries_controller.rb`
- Create: `app/views/suppliers/index.html.erb`
- Create: `app/views/suppliers/show.html.erb`
- Create: `app/views/suppliers/_filters.html.erb`
- Create: `app/views/suppliers/_supplier.html.erb`
- Create: `app/views/inquiries/new.html.erb`
- Create: `app/views/inquiries/create.html.erb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Create: `test/controllers/suppliers_controller_test.rb`
- Create: `test/controllers/inquiries_controller_test.rb`
- Create: `test/system/supplier_inquiry_flow_test.rb`

**Interfaces:** `GET /suppliers?company_type=&material=&region=`; `GET /inquiries/new` accepts calculator values as display defaults; `POST /inquiries` accepts raw calculator inputs and optional active `supplier_id`.

- [ ] Write failing supplier tests for type/material/region filters, combined filters, promoted labeling, card show, 404 for inactive/unknown slug, and empty results.
- [ ] Write failing inquiry tests for successful general/supplier-specific creation, invalid email/fields, unknown material, and Review Focus #4: inactive or forged supplier ID plus ignored client-submitted estimated prices.
- [ ] Assert the saved estimates equal a fresh `PackagingEstimator.call(**inquiry.calculator_attributes)` result.
- [ ] Write a failing system test from supplier list to detail to inquiry confirmation, including the explicit “учебная заявка не отправлена компании” message.
- [ ] Run the three test files and confirm failures.
- [ ] Implement filter scopes as composable controller queries over `Supplier.available`; avoid SQL built from raw user strings and use `distinct` after material joins.
- [ ] Recalculate estimates on create, copy only service results into estimate columns, and validate supplier availability before association.
- [ ] Render the desktop comparison table and mobile supplier cards from the same collection/partial; ensure `Реклама` appears for `promoted` records.
- [ ] Run focused and full tests; manually verify query parameters survive navigation from calculator to inquiry.
- [ ] Commit: `git add app/controllers app/views/suppliers app/views/inquiries app/assets/stylesheets test && git commit -m "feat: add supplier and inquiry flow"`.

## Task 9: Implement media, categories, and publication pages

**Files:**

- Create: `app/controllers/posts_controller.rb`
- Create: `app/controllers/categories_controller.rb`
- Create: `app/views/posts/index.html.erb`
- Create: `app/views/posts/show.html.erb`
- Create: `app/views/posts/_post.html.erb`
- Create: `app/views/categories/show.html.erb`
- Modify: `app/helpers/application_helper.rb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Create: `test/controllers/posts_controller_test.rb`
- Create: `test/controllers/categories_controller_test.rb`
- Create: `test/system/media_flow_test.rb`

**Interfaces:** `GET /media?category=:slug`; `Post.publicly_visible`; `related_posts(post, limit: 3)` or equivalent private query in controller.

- [ ] Write failing tests for published index, category filtering, featured ordering, slug show, 404 on draft, 404 on future publication, and absence of both from any public list.
- [ ] Write failing category tests for description and only public associated posts; include Review Focus #2 direct URL cases.
- [ ] Write a failing system test: media list → category → publication → calculator/material CTA.
- [ ] Run focused tests and confirm missing controllers/views.
- [ ] Implement eager-loaded queries to avoid N+1 category lookups and keep all visibility rules in `Post.publicly_visible`.
- [ ] Render `body` as escaped paragraphs (`simple_format` over plain text), never `raw` or user HTML; render local cover asset only after mapping to a known asset name.
- [ ] Match the visual language of Figma frame `203:271`, replacing placeholder blocks with real seeded posts and meaningful alt text.
- [ ] Run focused and full tests; manually verify draft/future URLs return 404.
- [ ] Commit: `git add app/controllers app/views/posts app/views/categories app/helpers app/assets/stylesheets test && git commit -m "feat: add editorial media pages"`.

## Task 10: Implement the packaging materials catalogue

**Files:**

- Create: `app/controllers/materials_controller.rb`
- Create: `app/views/materials/index.html.erb`
- Create: `app/views/materials/show.html.erb`
- Create: `app/views/materials/_material.html.erb`
- Create: `app/views/materials/_score.html.erb`
- Modify: `app/helpers/application_helper.rb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Create: `test/controllers/materials_controller_test.rb`
- Create: `test/system/materials_flow_test.rb`

**Interfaces:** `GET /materials?use_case=query`; `score_dots(score, label:)` returns accessible presentation without relying on color alone.

- [ ] Write failing controller tests for list, slug show, case-insensitive use-case filter, unknown slug and empty results.
- [ ] Write a failing system test from filtered catalogue to a detail page and onward to calculator/suppliers.
- [ ] Assert every score has a textual value such as `3 из 5`, not only colored dots.
- [ ] Run focused tests and confirm failures.
- [ ] Implement escaped text matching against `use_cases`, eager-load suppliers on detail, and show the four comparative scores plus the non-standard disclaimer.
- [ ] Derive card proportions and border/radius treatment from Figma frame `203:469`; reuse shared chips/buttons rather than introducing page-only variants.
- [ ] Run focused and full tests; verify 375 px cards and filters without horizontal overflow.
- [ ] Commit: `git add app/controllers/materials_controller.rb app/views/materials app/helpers app/assets/stylesheets test && git commit -m "feat: add packaging materials catalogue"`.

## Task 11: Assemble the Figma homepage, about page, subscription, and repeat-order demo

**Files:**

- Modify: `app/controllers/home_controller.rb`
- Modify: `app/controllers/pages_controller.rb`
- Create: `app/controllers/subscriptions_controller.rb`
- Modify: `app/views/home/show.html.erb`
- Create: `app/views/home/_hero.html.erb`
- Create: `app/views/home/_tools.html.erb`
- Create: `app/views/home/_steps.html.erb`
- Create: `app/views/home/_supplier_comparison.html.erb`
- Create: `app/views/home/_media.html.erb`
- Create: `app/views/home/_repeat_order.html.erb`
- Create: `app/views/home/_manufacturer_cta.html.erb`
- Modify: `app/views/pages/about.html.erb`
- Create: `app/views/subscriptions/_form.html.erb`
- Create: `app/javascript/controllers/repeat_order_controller.js`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Create: `test/controllers/home_controller_test.rb`
- Create: `test/controllers/pages_controller_test.rb`
- Create: `test/controllers/subscriptions_controller_test.rb`
- Create: `test/system/homepage_flow_test.rb`

**Interfaces:** homepage exposes selected materials, active suppliers, and public posts; subscription create responds to HTML/Turbo; repeat-order values equal the calculator reference fixture.

- [ ] Write failing home tests proving featured public posts, active suppliers and materials come from DB, while draft/future/inactive rows are absent.
- [ ] Write failing subscription tests for valid save, invalid email, Review Focus #3 case/whitespace duplicate, Turbo response, and no real mail delivery.
- [ ] Write a failing system test covering the order of all Figma sections, short calculation, supplier/media links, subscription feedback, and repeat-order form population.
- [ ] Run focused tests and confirm failures.
- [ ] Implement `HomeController#show` with bounded eager-loaded queries; do not embed data arrays in ERB.
- [ ] Reproduce frame `206:1146` section order and visual hierarchy with semantic sections, CSS Grid/Flexbox and local Figma assets; absolute positioning is limited to local decoration.
- [ ] Use the same calculator partial/service on home and `/calculator`; short form state must carry to the full calculator through query parameters or shared field names.
- [ ] Implement repeat-order controller to fill candles, 90×90×110, microcorrugated board, 500, Moscow and scroll/focus the calculator; label it as fixed demo data.
- [ ] Implement about copy and subscription feedback with server-side validation; no mailer job.
- [ ] Run focused/full tests and visually compare full page at 1440, 1024, 768 and 375 px against Figma.
- [ ] Commit: `git add app/controllers app/views/home app/views/pages app/views/subscriptions app/javascript/controllers/repeat_order_controller.js app/assets/stylesheets test && git commit -m "feat: build Figma-driven homepage"`.

## Task 12: Protect the admin namespace with session authentication

**Files:**

- Create: `app/controllers/admin/base_controller.rb`
- Create: `app/controllers/admin/sessions_controller.rb`
- Create: `app/controllers/admin/dashboard_controller.rb`
- Create: `app/helpers/admin/application_helper.rb`
- Create: `app/views/layouts/admin.html.erb`
- Create: `app/views/admin/sessions/new.html.erb`
- Create: `app/views/admin/dashboard/show.html.erb`
- Create: `app/assets/stylesheets/admin.css`
- Create: `test/controllers/admin/sessions_controller_test.rb`
- Create: `test/controllers/admin/dashboard_controller_test.rb`
- Create: `test/system/admin_authentication_test.rb`

**Interfaces:** session key `session[:admin_id]`; helpers `current_admin`, `admin_signed_in?`; unauthenticated admin requests redirect to `new_admin_session_path`.

- [ ] Write failing tests for login success/failure, normalized email login, logout, session fixation protection, and dashboard redirect when unauthenticated.
- [ ] Write a failing system test covering login, dashboard counters, logout, and inability to return to a protected page.
- [ ] Run focused tests and confirm failures.
- [ ] Implement `Admin::BaseController#require_admin` and helper exposure; skip only for session new/create.
- [ ] Call `reset_session` before setting a successful login and after logout; use generic failure text so account existence is not disclosed.
- [ ] Build a minimal admin shell distinct from public navigation, using the existing design tokens and accessible forms.
- [ ] Run focused/full tests and `bin/brakeman --no-pager`; address any authentication warning before commit.
- [ ] Commit: `git add app/controllers/admin app/helpers/admin app/views/admin app/views/layouts/admin.html.erb app/assets/stylesheets test && git commit -m "feat: secure admin workspace"`.

## Task 13: Add admin CRUD for categories and posts

**Files:**

- Create: `app/controllers/admin/categories_controller.rb`
- Create: `app/controllers/admin/posts_controller.rb`
- Create: `app/views/admin/categories/index.html.erb`
- Create: `app/views/admin/categories/show.html.erb`
- Create: `app/views/admin/categories/new.html.erb`
- Create: `app/views/admin/categories/edit.html.erb`
- Create: `app/views/admin/categories/_form.html.erb`
- Create: `app/views/admin/posts/index.html.erb`
- Create: `app/views/admin/posts/show.html.erb`
- Create: `app/views/admin/posts/new.html.erb`
- Create: `app/views/admin/posts/edit.html.erb`
- Create: `app/views/admin/posts/_form.html.erb`
- Create: `app/views/admin/shared/_form_errors.html.erb`
- Create: `test/controllers/admin/categories_controller_test.rb`
- Create: `test/controllers/admin/posts_controller_test.rb`
- Create: `test/system/admin_editorial_crud_test.rb`

**Interfaces:** standard REST helpers under `admin_*`; strong params enumerate only Data Contract fields; destructive actions require Turbo confirmation.

- [ ] Write failing controller tests for every CRUD action, unauthorized access, invalid render status 422, strong-parameter rejection, and category deletion blocked when posts exist.
- [ ] Write a failing system test creating a category and draft post, editing/publishing it, confirming it appears publicly, then deleting only safe records.
- [ ] Run focused tests and confirm failures.
- [ ] Implement thin controllers with explicit `category_params` and `post_params`; preload categories for post forms and render validation errors beside fields.
- [ ] Render status/kind selects from enum keys with Russian labels in a helper; do not persist translated display strings.
- [ ] Add Turbo-confirmed delete controls only where model constraints allow; show a clear alert on `ActiveRecord::DeleteRestrictionError`.
- [ ] Run focused/full tests and `bin/brakeman --no-pager`.
- [ ] Commit: `git add app/controllers/admin app/views/admin test && git commit -m "feat: manage editorial content in admin"`.

## Task 14: Add admin CRUD for marketplace data and lead review

**Files:**

- Create: `app/controllers/admin/materials_controller.rb`
- Create: `app/controllers/admin/suppliers_controller.rb`
- Create: `app/controllers/admin/subscriptions_controller.rb`
- Create: `app/controllers/admin/inquiries_controller.rb`
- Create: `app/views/admin/materials/index.html.erb`
- Create: `app/views/admin/materials/show.html.erb`
- Create: `app/views/admin/materials/new.html.erb`
- Create: `app/views/admin/materials/edit.html.erb`
- Create: `app/views/admin/materials/_form.html.erb`
- Create: `app/views/admin/suppliers/index.html.erb`
- Create: `app/views/admin/suppliers/show.html.erb`
- Create: `app/views/admin/suppliers/new.html.erb`
- Create: `app/views/admin/suppliers/edit.html.erb`
- Create: `app/views/admin/suppliers/_form.html.erb`
- Create: `app/views/admin/subscriptions/index.html.erb`
- Create: `app/views/admin/inquiries/index.html.erb`
- Create: `app/views/admin/inquiries/show.html.erb`
- Create: `test/controllers/admin/materials_controller_test.rb`
- Create: `test/controllers/admin/suppliers_controller_test.rb`
- Create: `test/controllers/admin/subscriptions_controller_test.rb`
- Create: `test/controllers/admin/inquiries_controller_test.rb`
- Create: `test/system/admin_marketplace_crud_test.rb`

**Interfaces:** supplier form sends `material_ids: []`, `regions_text`, `services_text`; controller converts newline/comma text to normalized arrays; inquiry update permits only `status`.

- [ ] Write failing CRUD tests for materials/suppliers, including score validation, material assignment replacement, active/promoted flags, strong params, and dependent relationship behavior.
- [ ] Write failing read-only subscription tests and inquiry index/show/status-update tests; prove inquiry estimated amounts and calculator inputs cannot be altered through admin status update.
- [ ] Write a failing system test creating a material/supplier, observing it publicly, deactivating it, reviewing a lead, and changing lead status.
- [ ] Run focused tests and confirm failures.
- [ ] Implement CRUD controllers and shared admin form patterns; normalize region/service text without accepting arbitrary nested hashes.
- [ ] Keep subscriptions read-only and permit only enum status for inquiry update; show timestamps and whether the inquiry is general or supplier-specific.
- [ ] Run focused/full tests, `bin/brakeman --no-pager`, and `bin/rubocop`.
- [ ] Commit: `git add app/controllers/admin app/views/admin test && git commit -m "feat: manage marketplace data and leads"`.

## Task 15: Add accessibility, responsive, and complete-flow system coverage

**Files:**

- Modify: `app/assets/stylesheets/components.css`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Modify: `app/views/shared/_header.html.erb`
- Modify: `app/views/calculator/_form.html.erb`
- Modify: `app/views/calculator/_result.html.erb`
- Modify: `app/views/suppliers/_supplier.html.erb`
- Modify: `app/views/materials/_material.html.erb`
- Modify: `app/views/materials/_score.html.erb`
- Modify: `app/views/home/show.html.erb`
- Modify: `app/views/inquiries/new.html.erb`
- Create: `test/system/public_journey_test.rb`
- Create: `test/system/responsive_layout_test.rb`
- Create: `test/system/accessibility_smoke_test.rb`

**Interfaces:** public journey is media/material → calculator → suppliers → inquiry; viewport helper resizes to each control width and checks document overflow.

- [ ] Write a failing complete-journey system test using seeded/fixture-equivalent data and asserting every transition plus the educational disclaimers.
- [ ] Write viewport tests at 1440, 1024, 768 and 375 px; at each width assert `document.documentElement.scrollWidth <= window.innerWidth`, usable navigation, visible primary CTA, and supplier table/card mode.
- [ ] Write accessibility smoke assertions for a single H1, associated labels, alt/decorative handling, keyboard menu, focus visibility hooks, status messages and non-color-only scores.
- [ ] Run these tests and record actual failures before CSS/view changes.
- [ ] Correct responsive grids, text wrapping, touch target sizes, table/card switching and focus states without creating duplicate semantic content for assistive technologies.
- [ ] Verify reduced-motion mode disables smooth/ornamental animation while keeping repeat-order focus movement understandable.
- [ ] Run all system tests, then `bin/rails test`; manually inspect screenshots at all four widths.
- [ ] Commit: `git add app/assets/stylesheets app/views test/system && git commit -m "test: harden responsive public journeys"`.

## Task 16: Document, audit, and prepare the local handoff

**Files:**

- Modify: `README.md`

**Interfaces:** documented commands are copy/paste runnable from repository root; no deployment or push is performed.

- [ ] Replace the generated README with prerequisites, `bin/setup`, database/seed commands, server start, safe admin ENV creation, test commands, model diagram/list, route summary, calculator caveat and privacy/demo caveat.
- [ ] Add a 3–5 minute teacher demo script: homepage → reference 24 ₽ calculation → filtered supplier → demo inquiry → media/material → admin login and content change.
- [ ] Add a requirement checklist mapped to implemented routes/features and note intentionally excluded MVP scope.
- [ ] Run `bin/setup --skip-server` in a clean-enough local state or document why it cannot be safely simulated; verify the README command sequence.
- [ ] Run final checks: `bin/rails test`, `bin/rubocop`, `bin/brakeman --no-pager`, `bin/bundler-audit check --update` (request network permission only if necessary).
- [ ] Run `rg -n "figma\.com|s3-alpha|ADMIN_PASSWORD|password\s*=" app db README.md` and inspect every match for temporary URLs or secrets.
- [ ] Run `git status --short`, `git diff --check`, and inspect `git diff origin/main...HEAD --stat`; do not push.
- [ ] Commit documentation/final fixes: `git add README.md <only-needed-fixes> && git commit -m "docs: prepare Upakovano MVP handoff"`.

## Completion Criteria

- The reference calculator result is exactly 24 ₽ per unit and is covered by a unit test.
- All public pages in the Route Contract render and use database records where specified.
- Draft/future posts and inactive suppliers are unavailable publicly.
- Subscription and inquiry failure/success states are understandable; no real email/vendor send is implied.
- Admin authentication protects every admin resource; CRUD and lead status operations are tested.
- Re-running seeds is idempotent and no admin is created without both secure ENV values.
- The homepage and calculator match the composition and visual language of the authoritative Figma frames with local assets.
- There is no horizontal overflow at 375 px and core flows work at all four control widths.
- `bin/rails test`, `bin/rubocop`, `bin/brakeman --no-pager`, and dependency audit pass or any external advisory outage is explicitly documented.
- README allows another person to launch and demonstrate the project without hidden knowledge.
- Work remains local until the user separately authorizes GitHub publication.
