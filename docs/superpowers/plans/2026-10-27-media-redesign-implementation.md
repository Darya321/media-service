# Media Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Перестроить `/media` в рабочую редакционную витрину с поиском, тематическими подборками и явно маркированными размещениями поставщиков.

**Architecture:** Существующая Rails-модель `Post` остаётся единственным источником редакционного контента и получает небольшое расширение для связи с поставщиком и типа размещения. `PostsController#index` формирует либо поисковую выдачу, либо три серверные подборки; отдельные ERB partials отвечают за героя, карточку и рекламный блок. Поиск остаётся простым SQL-поиском по трём полям и не добавляет зависимостей.

**Tech Stack:** Ruby on Rails 8.1, Active Record/SQLite, ERB, Propshaft, CSS Grid/Flexbox, Minitest/Capybara.

**Spec:** `docs/superpowers/specs/2026-10-27-media-redesign-design.md`

## Global Constraints

- Исходное состояние «Оригинал» остаётся доступно в Git-коммите `65d4451`.
- Использовать только существующие локальные изображения из `app/assets/images`; новые внешние и сгенерированные изображения не добавлять.
- Публикациями и рекламными размещениями управляет только существующий администратор.
- Не добавлять счётчики просмотров, аналитику, биллинг, регистрацию или личные кабинеты поставщиков.
- Публично доступны только опубликованные материалы без будущей даты публикации.
- Внешний CTA разрешает только абсолютные URL со схемой `http` или `https` и явно обозначается в интерфейсе.
- Поиск и фильтры выполняются сервером, работают совместно и не требуют JavaScript.
- Все изменения поведения разрабатываются через цикл RED → GREEN → REFACTOR.

## Review Focus

- Запрос с `%`, `_` или смешанным регистром должен рассматриваться как обычный текст и не расширять SQL-шаблон — закрепить в Task 2.
- Неизвестный `category` должен вернуть успешную страницу с пустым состоянием, а не показать все материалы — закрепить в Task 2.
- Черновик или будущая публикация не должна появиться ни в герое, ни в результатах, ни в подборках — закрепить в Task 2.
- `partner` без поставщика и `external` без безопасного URL не должны сохраняться; опасные схемы URL отклоняются — закрепить в Task 1.
- После обнуления связи с удалённым поставщиком партнёрская запись не должна создавать сломанную рекламную кнопку — закрепить в Task 1 и Task 3.

---

### Task 1: Расширить публикацию типом размещения и связью с поставщиком

**Files:**
- Create: `db/migrate/20261027001000_add_promotion_fields_to_posts.rb`
- Modify: `db/schema.rb`
- Modify: `app/models/post.rb`
- Modify: `app/models/supplier.rb`
- Modify: `test/fixtures/posts.yml`
- Test: `test/models/post_test.rb`

**Interfaces:**
- Consumes: существующие `Post.publicly_visible`, `Supplier` и slug-маршруты.
- Produces: `Post.placements` со значениями `editorial`, `partner`, `external`; `Post#supplier`; `Post.promotable`; поля `cta_label` и `external_url`.

- [ ] **Step 1: Написать падающие модельные тесты**

Добавить проверки точного набора `Post.placements`, необязательной связи обычной публикации, обязательного поставщика для `partner`, обязательного безопасного `http`/`https` URL для `external`, отклонения `javascript:` и исключения осиротевшего партнёрского материала из `Post.promotable`.

- [ ] **Step 2: Запустить модельный тест и подтвердить RED**

Run: `bin/rails test test/models/post_test.rb`

Expected: FAIL из-за отсутствующих `placement`, `supplier` и `promotable`.

- [ ] **Step 3: Добавить миграцию полей размещения**

Создать nullable `supplier_id` с внешним ключом `on_delete: :nullify`, `placement:integer` с `default: 0, null: false`, nullable `cta_label:string` и `external_url:string`; добавить индексы для `supplier_id` и `placement`.

- [ ] **Step 4: Реализовать интерфейс модели**

В `Post` добавить `belongs_to :supplier, optional: true`, enum `placement`, условные валидации и scope `promotable`, который возвращает только корректно адресуемые партнёрские и внешние размещения. В `Supplier` добавить `has_many :posts, dependent: :nullify`.

- [ ] **Step 5: Обновить тестовую схему и fixtures**

Run: `bin/rails db:migrate RAILS_ENV=test`

Дополнить fixtures валидным партнёрским материалом и внешним размещением, не меняя публичность существующих записей.

- [ ] **Step 6: Запустить модельные тесты и подтвердить GREEN**

Run: `bin/rails test test/models/post_test.rb test/models/supplier_test.rb`

Expected: PASS, 0 failures, 0 errors.

- [ ] **Step 7: Зафиксировать этап**

```bash
git add db/migrate/20261027001000_add_promotion_fields_to_posts.rb db/schema.rb app/models/post.rb app/models/supplier.rb test/models/post_test.rb test/fixtures/posts.yml
git commit -m "feat: model media placements"
```

### Task 2: Добавить рабочий поиск, фильтры и серверные подборки

**Files:**
- Modify: `app/models/post.rb`
- Modify: `app/controllers/posts_controller.rb`
- Test: `test/models/post_test.rb`
- Test: `test/controllers/posts_controller_test.rb`

**Interfaces:**
- Consumes: `Post.publicly_visible`, `Post.promotable`, категории со slug `materials`, `suppliers`, `business-cases`, `legislation`.
- Produces: `Post.search_for(query)`; `@hero_post`, `@media_categories`, `@selected_category`, `@query`, `@filtering`, `@posts`, `@supplier_posts`, `@business_feature`, `@legislation_posts`, `@subscription`.

- [ ] **Step 1: Написать падающие тесты поиска**

В `PostTest` проверить нечувствительный к регистру поиск по `title`, `summary`, `body`, возврат relation для пустой строки и буквальное экранирование `%`/`_` через `ActiveRecord::Base.sanitize_sql_like`.

- [ ] **Step 2: Написать падающие controller tests страницы**

Проверить героя из избранной записи; совместный `q` + `category`; неизвестную категорию с пустым состоянием; отсутствие draft/future во всех наборах; наличие отдельных supplier/business/legislation подборок без активного фильтра.

- [ ] **Step 3: Запустить новые тесты и подтвердить RED**

Run: `bin/rails test test/models/post_test.rb test/controllers/posts_controller_test.rb`

Expected: FAIL на отсутствующем `search_for` и новых assignments/селекторах.

- [ ] **Step 4: Реализовать `Post.search_for(query)`**

Метод возвращает `all` для blank-строки; иначе применяет один параметризованный SQL-шаблон к `LOWER(title)`, `LOWER(summary)` и `LOWER(body)` с экранированной подстрокой.

- [ ] **Step 5: Собрать данные в `PostsController#index`**

Нормализовать `q`, разрешать только существующую категорию, сохранять неизвестный slug как пустую выборку, предзагружать `category` и `supplier`, не допускать draft/future и ограничить каждую подборку тремя публикациями. Герой выбирается как первая избранная, затем как первая свежая публикация.

- [ ] **Step 6: Запустить controller/model tests и подтвердить GREEN**

Run: `bin/rails test test/models/post_test.rb test/controllers/posts_controller_test.rb`

Expected: PASS, 0 failures, 0 errors.

- [ ] **Step 7: Зафиксировать этап**

```bash
git add app/models/post.rb app/controllers/posts_controller.rb test/models/post_test.rb test/controllers/posts_controller_test.rb
git commit -m "feat: search and group media content"
```

### Task 3: Собрать новую публичную страницу и рекламные переходы

**Files:**
- Create: `app/views/posts/_media_card.html.erb`
- Create: `app/views/posts/_media_feature.html.erb`
- Create: `app/views/posts/_media_promotion.html.erb`
- Modify: `app/views/posts/index.html.erb`
- Modify: `app/views/posts/show.html.erb`
- Modify: `app/helpers/application_helper.rb`
- Modify: `app/assets/stylesheets/public.css`
- Modify: `app/assets/stylesheets/responsive.css`
- Test: `test/controllers/posts_controller_test.rb`
- Test: `test/system/media_flow_test.rb`
- Test: `test/system/responsive_layout_test.rb`

**Interfaces:**
- Consumes: assignments Task 2 и `Post#placement`/`Post#supplier` Task 1.
- Produces: `post_cover_asset(post)`, `post_placement_label(post)`, `post_cta_url(post)`, `post_external_cta?(post)`; DOM hooks `.media-hero`, `.media-toolbar`, `.media-results`, `.media-section`, `.media-promotion`, `.media-subscription`.

- [ ] **Step 1: Написать падающие render/system tests**

Проверить форму `GET /media` с полями `q` и `category`, сохранение `q` в filter links, маркировку партнёрского материала, внутренний CTA на `supplier_path`, внешний CTA с текстовой пометкой и `rel="noopener noreferrer"`, пустое состояние и отсутствие сломанной кнопки у неполного размещения.

- [ ] **Step 2: Добавить падающий адаптивный smoke test**

Проверить наличие правил для `.media-hero`, `.media-toolbar`, `.media-section__grid`, `.media-promotion` внутри брейкпоинтов `900px` и `560px`.

- [ ] **Step 3: Запустить целевые тесты и подтвердить RED**

Run: `bin/rails test test/controllers/posts_controller_test.rb test/system/media_flow_test.rb test/system/responsive_layout_test.rb`

Expected: FAIL из-за отсутствующей новой разметки и helper-методов.

- [ ] **Step 4: Реализовать безопасные presentation helpers**

Расширить карту локальных обложек существующими файлами `figma/material-*.jpeg|png`; добавить подпись типа размещения и вычисление CTA: `partner` с поставщиком → `supplier_path`, `external` с валидным URL → URL, иначе `nil`.

- [ ] **Step 5: Собрать ERB-композицию из трёх partials**

`_media_feature` отвечает только за героя, `_media_card` — за карточку списка, `_media_promotion` — за широкий business CTA. `index` располагает toolbar, условную выдачу или три подборки и повторно использует `subscriptions/form`. `show` отображает рекламную маркировку и допустимый CTA после статьи.

- [ ] **Step 6: Оформить desktop/tablet/mobile состояния**

Добавить стили в существующую систему токенов: герой с локальным изображением, pill-фильтры, трёхколоночные карточки, широкий зелёный promotion-блок, подписку; на `900px` перейти к двум колонкам и вертикальному promotion, на `560px` — к одной колонке и полноширинным controls.

- [ ] **Step 7: Запустить целевые тесты и подтвердить GREEN**

Run: `bin/rails test test/controllers/posts_controller_test.rb test/system/media_flow_test.rb test/system/responsive_layout_test.rb`

Expected: PASS, 0 failures, 0 errors.

- [ ] **Step 8: Зафиксировать этап**

```bash
git add app/views/posts app/helpers/application_helper.rb app/assets/stylesheets/public.css app/assets/stylesheets/responsive.css test/controllers/posts_controller_test.rb test/system/media_flow_test.rb test/system/responsive_layout_test.rb
git commit -m "feat: redesign media landing page"
```

### Task 4: Добавить управление размещениями в админку

**Files:**
- Modify: `app/controllers/admin/posts_controller.rb`
- Modify: `app/views/admin/posts/_form.html.erb`
- Modify: `app/views/admin/posts/index.html.erb`
- Modify: `app/views/admin/posts/show.html.erb`
- Modify: `app/helpers/admin/application_helper.rb`
- Test: `test/controllers/admin/posts_controller_test.rb`
- Test: `test/system/admin_editorial_crud_test.rb`

**Interfaces:**
- Consumes: `Post.placements`, `Supplier.available` и поля Task 1.
- Produces: разрешённые параметры `supplier_id`, `placement`, `cta_label`, `external_url`; select-поля админки и русские подписи типов размещения.

- [ ] **Step 1: Написать падающие admin tests**

Проверить наличие новых полей на `new/edit`, создание партнёрской публикации со связью, создание внешнего размещения, отсутствие mass assignment постороннего параметра и показ ошибок условной валидации с HTTP 422.

- [ ] **Step 2: Запустить admin tests и подтвердить RED**

Run: `bin/rails test test/controllers/admin/posts_controller_test.rb test/system/admin_editorial_crud_test.rb`

Expected: FAIL из-за отсутствующих полей и strong parameters.

- [ ] **Step 3: Обновить controller и helper**

Загружать `@suppliers = Supplier.available.order(:name)` для четырёх form actions, разрешить четыре новых поля и добавить русские option/label helpers для `editorial`, `partner`, `external`.

- [ ] **Step 4: Обновить формы и обзорные страницы**

Добавить select типа размещения, необязательный supplier select, CTA label и external URL с объясняющим текстом; показать тип размещения и компанию в index/show без скрытия существующих данных.

- [ ] **Step 5: Расширить системный CRUD-сценарий**

В `AdminEditorialCrudTest` создать партнёрскую публикацию, выбрать существующего поставщика, опубликовать её и проверить видимый CTA на публичной странице.

- [ ] **Step 6: Запустить admin tests и подтвердить GREEN**

Run: `bin/rails test test/controllers/admin/posts_controller_test.rb test/system/admin_editorial_crud_test.rb`

Expected: PASS, 0 failures, 0 errors.

- [ ] **Step 7: Зафиксировать этап**

```bash
git add app/controllers/admin/posts_controller.rb app/views/admin/posts app/helpers/admin/application_helper.rb test/controllers/admin/posts_controller_test.rb test/system/admin_editorial_crud_test.rb
git commit -m "feat: manage media placements in admin"
```

### Task 5: Наполнить подборки и провести полную проверку

**Files:**
- Modify: `db/seeds.rb`
- Modify: `test/integration/seeds_test.rb`
- Modify: `test/fixtures/categories.yml`
- Modify: `test/fixtures/posts.yml`
- Test: `test/system/public_journey_test.rb`
- Test: `test/system/accessibility_smoke_test.rb`

**Interfaces:**
- Consumes: категории, размещения и публичную композицию Tasks 1–4.
- Produces: категория `legislation`, минимум по одному демонстрационному материалу каждой подборки, внутренний партнёрский и внешний рекламный CTA.

- [ ] **Step 1: Написать падающий seed test**

Проверить повторяемость сидов, наличие `legislation`, партнёрского материала с `supplier`, внешнего размещения с безопасным URL и отсутствие счётчиков/аналитических полей в `posts`.

- [ ] **Step 2: Запустить seed test и подтвердить RED**

Run: `bin/rails test test/integration/seeds_test.rb`

Expected: FAIL из-за отсутствующих новых демонстрационных записей.

- [ ] **Step 3: Расширить повторяемые сиды и fixtures**

Добавить категорию законодательства и материалы трёх подборок, используя существующих поставщиков и `cover_asset` ключи локальных изображений. Обновление по slug должно сохранять стабильное число записей при повторном запуске.

- [ ] **Step 4: Обновить сквозные и accessibility smoke tests**

Проверить путь `/media` → поиск/фильтр → публикация → внутренний поставщик и доступные имена search/filter/CTA controls; не добавлять проверки метрик просмотров.

- [ ] **Step 5: Запустить полный набор Rails-тестов**

Run: `bin/rails test`

Expected: PASS, 0 failures, 0 errors.

- [ ] **Step 6: Запустить системные тесты**

Run: `bin/rails test:system`

Expected: PASS, 0 failures, 0 errors.

- [ ] **Step 7: Запустить статические проверки**

Run: `bin/rubocop`

Expected: no offenses.

Run: `bin/brakeman --no-pager`

Expected: 0 warnings.

Run: `bin/bundler-audit check --update`

Expected: No vulnerabilities found.

- [ ] **Step 8: Проверить страницу визуально**

Запустить приложение, открыть `/media` и проверить 1440px, 768px и 375px: отсутствие горизонтального переполнения, читаемость героя, controls, карточек, promotion и подписки; отдельно проверить состояние без результатов.

- [ ] **Step 9: Зафиксировать завершение**

```bash
git add db/seeds.rb test/integration/seeds_test.rb test/fixtures/categories.yml test/fixtures/posts.yml test/system/public_journey_test.rb test/system/accessibility_smoke_test.rb docs/superpowers/specs/2026-10-27-media-redesign-design.md docs/superpowers/plans/2026-10-27-media-redesign-implementation.md
git commit -m "test: complete media redesign"
```
