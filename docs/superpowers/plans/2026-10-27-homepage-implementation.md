# Упаковано Homepage Implementation Plan

> **Статус:** не исполнять как самостоятельный план. Документ относится к раннему прототипу без базы данных и административной панели. Он сохранён для истории; новый поэтапный план будет подготовлен после утверждения `docs/superpowers/specs/2026-10-27-upakovano-mvp-design.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Создать в существующем Rails-приложении адаптивную главную страницу «Упаковано», визуально соответствующую макету и демонстрирующую работу калькулятора, фильтров поставщиков и основных действий без сохранения данных.

**Architecture:** Серверная часть отдаёт одну страницу и небольшие наборы демонстрационных данных через обычные Rails controller и ERB partials. Stimulus управляет только локальным состоянием калькулятора, фильтрами и интерфейсными сообщениями; данные не сохраняются и не требуют миграций. CSS разделён на токены, раскладку, компоненты и адаптивные правила, а исходный статичный макет остаётся визуальным эталоном.

**Tech Stack:** Ruby 4.0.6, Ruby on Rails 8.1.4, ERB, Propshaft, Importmap, Turbo, Stimulus, Minitest, Capybara, Selenium.

**Spec:** `docs/superpowers/specs/2026-10-26-homepage-design.md`

## Global Constraints

- Работать только в существующем приложении Ruby on Rails 8.1.4; не создавать новое приложение и не переходить на React, Next.js или другой фронтенд-фреймворк.
- На этом этапе не создавать модели, миграции, административную панель, авторизацию, отдельные страницы публикаций и реальную отправку заявок.
- Главный визуальный эталон — переданный макет 1353 × 4096 пикселей; спецификация определяет поведение и адаптивность, которых нет на статичном макете.
- Начальное состояние калькулятора: свечи, 500 штук, 90 × 90 × 110 мм, микрогофрокартон, Москва и 24 ₽ за штуку.
- Любая рассчитанная цена должна быть подписана как предварительная; точную цену сообщает поставщик.
- Все визуально активные кнопки должны выполнять действие или показывать явное сообщение о демонстрационном режиме.
- Страница должна оставаться читаемой и не иметь горизонтальной прокрутки на ширинах 1440, 1024, 768 и 375 пикселей.
- Не подключать сетевые шрифты, внешние API и дополнительные JavaScript-библиотеки.

## Review Focus

- Нулевой, отрицательный или очень большой тираж и некорректные размеры не должны выводить `NaN`, `Infinity` или ломать график — проверяется в Task 3.
- Пустой или некорректный бюджет не должен приводить к ложному сообщению «в бюджете» — проверяется в Task 3.
- Сочетание региона и категории без подходящих поставщиков должно показывать явное пустое состояние — проверяется в Task 4.
- Мобильное меню должно синхронизировать видимость и `aria-expanded`, а после выбора якоря закрываться — проверяется в Task 5.
- На ширине 375 пикселей ни один блок не должен расширять документ за пределы viewport — проверяется в Task 5.

---

### Task 1: Rails route, controller and demo content contract

**Files:**
- Create: `app/controllers/home_controller.rb`
- Create: `app/views/home/index.html.erb`
- Create: `test/controllers/home_controller_test.rb`
- Modify: `config/routes.rb`
- Modify: `app/views/layouts/application.html.erb`

**Interfaces:**
- Consumes: существующий `ApplicationController`, стандартный layout Rails и root URL.
- Produces: `root_path`, `HomeController#index`, а также `@steps`, `@suppliers` и `@media_items` как массивы хешей для partials следующих задач.

- [ ] **Step 1: Write the failing root-page test**

Создать `HomeControllerTest` с тестом `test_renders_the_homepage_content_contract`, который выполняет `get root_url` и проверяет:

```ruby
assert_response :success
assert_select "html[lang='ru']"
assert_select "title", text: /Упаковано/
assert_select "main#main-content"
assert_select "section#calculator"
assert_select "section#suppliers"
assert_select "section#media"
```

- [ ] **Step 2: Run the test and confirm the missing route failure**

Run: `bin/rails test test/controllers/home_controller_test.rb`

Expected: FAIL because `/` has no application route or `HomeController` does not exist.

- [ ] **Step 3: Add the root route and controller data contract**

В `config/routes.rb` определить `root "home#index"`. В `HomeController#index` присвоить:

- `@steps` — четыре хеша с ключами `number`, `title`, `description`, `accent`;
- `@suppliers` — три хеша с ключами `name`, `specialization`, `category`, `minimum_order`, `materials`, `unit_price`, `promoted`, `regions`;
- `@media_items` — три хеша с ключами `kind`, `title`, `summary`, `tone`.

Значения должны повторять тексты макета: четыре шага, «Крафт упаковка», «Крафт поставка», «Название типографии» и три материала про выбор упаковки, крафт и интервью.

- [ ] **Step 4: Add the minimal semantic page shell and Russian metadata**

В `index.html.erb` задать `content_for :title, "Упаковано — упаковка для бизнеса"`, создать `main#main-content` и временные секции `#calculator`, `#suppliers`, `#media`. В layout установить `lang="ru"`, `application-name="Упаковано"` и оставить подключение Importmap.

- [ ] **Step 5: Run the controller test**

Run: `bin/rails test test/controllers/home_controller_test.rb`

Expected: PASS.

- [ ] **Step 6: Commit the Rails shell**

```bash
git add app/controllers/home_controller.rb app/views/home/index.html.erb app/views/layouts/application.html.erb config/routes.rb test/controllers/home_controller_test.rb
git commit -m "feat: add homepage Rails shell"
```

---

### Task 2: Semantic sections and desktop visual system

**Files:**
- Create: `app/views/home/_header.html.erb`
- Create: `app/views/home/_hero.html.erb`
- Create: `app/views/home/_workflow.html.erb`
- Create: `app/views/home/_calculator.html.erb`
- Create: `app/views/home/_suppliers.html.erb`
- Create: `app/views/home/_media.html.erb`
- Create: `app/views/home/_repeat_order.html.erb`
- Create: `app/views/home/_producer_cta.html.erb`
- Create: `app/views/home/_footer.html.erb`
- Create: `app/assets/images/package-hero.svg`
- Create: `app/assets/stylesheets/home/tokens.css`
- Create: `app/assets/stylesheets/home/layout.css`
- Create: `app/assets/stylesheets/home/components.css`
- Modify: `app/views/home/index.html.erb`
- Modify: `app/views/layouts/application.html.erb`
- Modify: `app/assets/stylesheets/application.css`
- Modify: `test/controllers/home_controller_test.rb`

**Interfaces:**
- Consumes: `@steps`, `@suppliers`, `@media_items` from Task 1.
- Produces: стабильные section IDs `materials`, `calculator`, `suppliers`, `media`; Stimulus-ready data attributes and targets used by Tasks 3–5; CSS custom properties for all later styles.

- [ ] **Step 1: Expand the controller test for the complete page structure**

Добавить к `test_renders_the_homepage_content_contract` проверки:

```ruby
assert_select "header.site-header"
assert_select "a[href='#calculator']"
assert_select "section#workflow .workflow-card", count: 4
assert_select "section#calculator form[data-calculator-target='form']"
assert_select "section#suppliers [data-suppliers-target='row']", count: 3
assert_select "section#media .media-card", count: 3
assert_select "section#repeat-order"
assert_select "section#for-producers"
assert_select "footer.site-footer"
assert_select "img[src*='package-hero'][alt]"
```

- [ ] **Step 2: Run the controller test and confirm missing sections**

Run: `bin/rails test test/controllers/home_controller_test.rb`

Expected: FAIL because the partials and complete semantic markup are absent.

- [ ] **Step 3: Build the ERB partials and compose the page**

Собрать `index.html.erb` из девяти partials. Использовать `header`, `nav`, `main`, `section`, `article`, `form`, `table`, `footer`, связанные `label`/`input` и один `h1`. Навигационные элементы использовать как реальные якорные ссылки. Медиа-карточки оставить неинтерактивными. Кнопкам демонстрационных действий назначить `type="button"` и data attributes для контроллеров будущих задач.

- [ ] **Step 4: Add the local package illustration**

Создать `package-hero.svg` с геометрическими формами макета: тёмно-зелёная верхняя плоскость, коричневая нижняя форма и небольшая бежевая коробка. Вставить через `image_tag` с содержательным `alt`.

- [ ] **Step 5: Establish ordered stylesheet loading and design tokens**

В layout явно подключить в порядке `application`, `home/tokens`, `home/layout`, `home/components`; убрать зависимость от неявного порядка `:app`. В `tokens.css` определить custom properties:

```css
--color-canvas: #f2f1ed;
--color-ink: #11120f;
--color-forest: #274c20;
--color-lime: #baff3b;
--color-pale-lime: #e1f2b7;
--color-warm: #caa574;
--color-muted: #e3e2dc;
--color-line: #797a72;
--radius-card: 1.5rem;
--page-width: 82rem;
```

Разрешается слегка уточнить значения после визуального сравнения, сохранив отношения палитры.

- [ ] **Step 6: Implement the desktop layout and component styling**

В `application.css` добавить reset, базовую типографику, `scroll-behavior` с учётом `prefers-reduced-motion` и видимый `:focus-visible`. В `layout.css` определить контейнеры, вертикальный ритм и сетки. В `components.css` оформить кнопки, карточки, формы, таблицу, график, hero-сетку фона и все состояния из макета. Не добавлять адаптивные media queries до Task 5.

- [ ] **Step 7: Run the controller test and inspect the desktop page**

Run: `bin/rails test test/controllers/home_controller_test.rb`

Expected: PASS.

Run: `bin/rails server`

Expected: `http://localhost:3000/` показывает все блоки в порядке макета, без отсутствующих ассетов и ошибок в серверном логе.

- [ ] **Step 8: Commit the semantic desktop page**

```bash
git add app/views app/assets/stylesheets app/assets/images test/controllers/home_controller_test.rb
git commit -m "feat: build homepage design sections"
```

---

### Task 3: Demonstration calculator and repeat-order flow

**Files:**
- Create: `app/javascript/controllers/calculator_controller.js`
- Create: `test/application_system_test_case.rb`
- Create: `test/system/homepage_calculator_test.rb`
- Modify: `app/views/home/index.html.erb`
- Modify: `app/views/home/_hero.html.erb`
- Modify: `app/views/home/_calculator.html.erb`
- Modify: `app/views/home/_repeat_order.html.erb`
- Modify: `app/assets/stylesheets/home/components.css`

**Interfaces:**
- Consumes: calculator, hero and repeat-order data targets from Task 2.
- Produces: Stimulus actions `syncFromHero`, `calculate`, `showSuppliers`, `repeatOrder`; helper methods `parseDimensions(value)`, `quantityFactor(quantity)`, `calculateUnitPrice()`; window event `homepage:supplier-region` with detail `{ region: String }` for Task 4.

- [ ] **Step 1: Configure the Rails system-test base**

Создать `ApplicationSystemTestCase < ActionDispatch::SystemTestCase` с `driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1000]`.

- [ ] **Step 2: Write failing calculator behavior tests**

Создать системные тесты:

- `test_initial_example_shows_24_rubles` — цена содержит `24 ₽`, активная колонка графика имеет `data-quantity="500"`, рядом присутствует текст о предварительном расчёте;
- `test_quantity_material_and_dimensions_update_the_estimate` — при 1000 штуках, крафт-картоне и исходных размерах цена становится `18 ₽`;
- `test_invalid_inputs_never_render_non_finite_values` — значения `0`, `-5`, очень большой тираж и размеры `abc` не приводят к появлению `NaN` или `Infinity`, а неверные размеры показывают инструкцию о формате;
- `test_budget_feedback_requires_a_valid_budget` — пустой бюджет показывает нейтральное сообщение, а бюджет 15000 ₽ для партии стоимостью 18000 ₽ показывает превышение на 3000 ₽;
- `test_hero_form_and_repeat_order_fill_the_main_calculator` — hero-форма переносит свои значения вниз, а «Повторить заказ» устанавливает свечи, 500, 90 × 90 × 110 и крафт-картон.

- [ ] **Step 3: Run the system test and confirm missing behavior**

Run: `bin/rails test:system TEST=test/system/homepage_calculator_test.rb`

Expected: FAIL because `calculator_controller.js` and interactive state do not exist.

- [ ] **Step 4: Implement the deterministic demonstration formula**

В `calculator_controller.js` определить:

- базовую цену: свечи `24`, косметика `22`, продукты `20`, текстиль `18`;
- коэффициент материала: микрогофрокартон `1.00`, крафт-картон `0.88`, картон `0.92`;
- коэффициент тиража: до 100 `1.25`, до 300 `1.10`, до 500 `1.00`, до 1000 `0.86`, свыше 1000 `0.70`;
- коэффициент размера: кубический корень отношения объёма к эталону `90 × 90 × 110`, ограниченный диапазоном `0.70..2.00`;
- итоговую цену: округлённое целое произведение коэффициентов.

`parseDimensions(value)` возвращает три положительных числа либо `null`. Некорректный ввод выводит `— ₽` и инструкцию, а не нечисловое значение. Количество нормализуется минимум до 1 и безопасного конечного числа.

- [ ] **Step 5: Connect hero, calculator, chart and budget feedback**

Разместить `data-controller="calculator"` на общем контейнере страницы. Связать именованные targets для hero и основной формы, цены, budget status и пяти bar elements. `syncFromHero` копирует значения и прокручивает к `#calculator`; `calculate` обновляет цену, активную колонку и бюджет после `input`/`change`.

- [ ] **Step 6: Implement repeat order and supplier handoff**

`repeatOrder` устанавливает значения сохранённого примера и прокручивает к калькулятору. `showSuppliers` отправляет `homepage:supplier-region` через `window` и прокручивает к `#suppliers`.

- [ ] **Step 7: Run calculator tests**

Run: `bin/rails test:system TEST=test/system/homepage_calculator_test.rb`

Expected: PASS with no JavaScript console errors.

- [ ] **Step 8: Commit calculator behavior**

```bash
git add app/javascript/controllers/calculator_controller.js app/views/home app/assets/stylesheets/home/components.css test/application_system_test_case.rb test/system/homepage_calculator_test.rb
git commit -m "feat: add interactive packaging calculator"
```

---

### Task 4: Supplier filtering and honest demo actions

**Files:**
- Create: `app/javascript/controllers/suppliers_controller.js`
- Create: `app/javascript/controllers/demo_notice_controller.js`
- Create: `test/system/homepage_suppliers_test.rb`
- Modify: `app/views/home/_suppliers.html.erb`
- Modify: `app/views/home/_media.html.erb`
- Modify: `app/views/home/_producer_cta.html.erb`
- Modify: `app/assets/stylesheets/home/components.css`

**Interfaces:**
- Consumes: supplier hashes from Task 1 and `homepage:supplier-region` from Task 3.
- Produces: supplier actions `filter`, `setRegion`, `request`; generic demo action `demo-notice#show`; visible category and region status plus an `aria-live="polite"` message target.

- [ ] **Step 1: Write failing supplier and message tests**

Создать системные тесты:

- `test_category_buttons_filter_supplier_rows` — «Типографии» оставляет только «Название типографии», «Все» возвращает три строки;
- `test_region_from_calculator_limits_suppliers` — Санкт-Петербург и «Показать поставщиков» оставляют только поставщиков с соответствующим `data-regions`;
- `test_empty_combination_has_an_explicit_state` — «Студии дизайна» скрывает все строки и показывает «Пока нет демонстрационных компаний по этим условиям»;
- `test_request_and_future_feature_buttons_explain_demo_mode` — запрос, все материалы и размещение компании обновляют видимую `aria-live` область сообщением о том, что действие демонстрационное и данные не отправлены.

- [ ] **Step 2: Run the supplier system test and confirm missing controllers**

Run: `bin/rails test:system TEST=test/system/homepage_suppliers_test.rb`

Expected: FAIL because filters and notice behavior are absent.

- [ ] **Step 3: Add supplier categories, regions and empty state to the markup**

Каждая строка получает `data-category` и `data-regions` из controller data. Категорийные кнопки используют значения `all`, `factory`, `boxes`, `print`, `design`, `fulfillment`. Добавить скрываемый empty state, текст текущего регионального ограничения и `aria-pressed` на кнопках фильтра.

- [ ] **Step 4: Implement supplier filtering**

`suppliers_controller.js` хранит текущие `category` и `region`, реагирует на `homepage:supplier-region@window`, показывает строку только при совпадении обоих ограничений, обновляет `aria-pressed` и empty state. Регион `Вся Россия` совпадает с компаниями, у которых в `regions` указано `Россия`.

- [ ] **Step 5: Implement reusable demo notices**

`demo_notice_controller.js` читает текст из `data-demo-message` на нажатой кнопке и помещает его в ближайший `outputTarget`. Сообщения должны явно говорить: заявка не отправлена, раздел материалов будет на следующем этапе, форма размещения компании пока демонстрационная.

- [ ] **Step 6: Run supplier tests**

Run: `bin/rails test:system TEST=test/system/homepage_suppliers_test.rb`

Expected: PASS.

- [ ] **Step 7: Commit supplier interactions**

```bash
git add app/javascript/controllers/suppliers_controller.js app/javascript/controllers/demo_notice_controller.js app/views/home app/assets/stylesheets/home/components.css test/system/homepage_suppliers_test.rb
git commit -m "feat: add supplier filters and demo notices"
```

---

### Task 5: Mobile navigation, responsive layouts and overflow protection

**Files:**
- Create: `app/javascript/controllers/navigation_controller.js`
- Create: `app/assets/stylesheets/home/responsive.css`
- Create: `test/system/homepage_responsive_test.rb`
- Modify: `app/views/home/_header.html.erb`
- Modify: `app/views/layouts/application.html.erb`
- Modify: `app/assets/stylesheets/home/components.css`

**Interfaces:**
- Consumes: section IDs and design tokens from Task 2.
- Produces: `navigation#toggle`, `navigation#close`, accurate `aria-expanded`, responsive layouts at 1024/768/375 and a mobile supplier-card presentation.

- [ ] **Step 1: Write failing mobile navigation and overflow tests**

Создать системные тесты:

- `test_mobile_menu_toggles_and_closes_after_navigation` — при размере 375 × 812 кнопка открывает nav, устанавливает `aria-expanded="true"`, выбор «Калькулятор» закрывает nav и возвращает `aria-expanded="false"`;
- `test_mobile_layout_has_no_horizontal_document_overflow` — после загрузки и после открытия меню JavaScript-выражение `document.documentElement.scrollWidth <= window.innerWidth` возвращает `true`;
- `test_supplier_table_becomes_labeled_cards_on_mobile` — каждая видимая ячейка получает доступную подпись колонки через `data-label`, без необходимости читать заголовок за пределами экрана.

- [ ] **Step 2: Run the responsive system test and confirm failure**

Run: `bin/rails test:system TEST=test/system/homepage_responsive_test.rb`

Expected: FAIL because the menu controller and responsive stylesheet do not exist.

- [ ] **Step 3: Implement accessible mobile navigation**

Добавить кнопку с `aria-controls="primary-navigation"`, `aria-expanded="false"` и доступным названием. `navigation_controller.js` переключает скрытое состояние nav и атрибут; `close` срабатывает на якорных ссылках и Escape.

- [ ] **Step 4: Add ordered responsive stylesheet loading**

Подключить `home/responsive` после остальных homepage stylesheets в layout.

- [ ] **Step 5: Implement responsive breakpoints**

В `responsive.css` определить:

- до 1024 px: четырёхколоночный workflow становится двухколоночным, уменьшаются hero-типографика и отступы;
- до 768 px: hero, калькулятор и CTA становятся одноколоночными, показывается menu button, nav получает раскрываемое состояние;
- до 560 px: таблица поставщиков отображает строки как карточки с `data-label`, карточки медиа и hero складываются вертикально;
- до 375 px: минимальные боковые отступы 16 px, фоновые надписи ограничены, поля и кнопки занимают доступную ширину.

Ни один media query не должен скрывать содержательную информацию.

- [ ] **Step 6: Run responsive tests**

Run: `bin/rails test:system TEST=test/system/homepage_responsive_test.rb`

Expected: PASS.

- [ ] **Step 7: Commit responsive behavior**

```bash
git add app/javascript/controllers/navigation_controller.js app/assets/stylesheets/home app/views/home/_header.html.erb app/views/layouts/application.html.erb test/system/homepage_responsive_test.rb
git commit -m "feat: make homepage responsive"
```

---

### Task 6: Visual QA, complete verification and project handoff notes

**Files:**
- Modify: `README.md`
- Modify as needed after visual inspection: `app/assets/stylesheets/home/*.css`
- Modify as needed after behavior inspection: `app/views/home/*.html.erb`
- Modify as needed after behavior inspection: `app/javascript/controllers/*.js`

**Interfaces:**
- Consumes: completed homepage and all automated tests from Tasks 1–5.
- Produces: visually reviewed page, reproducible local-run instructions and factual verification record in the final handoff.

- [ ] **Step 1: Run the complete automated test suite**

Run: `bin/rails test`

Expected: all tests PASS with 0 failures and 0 errors.

Run: `bin/rails test:system`

Expected: all system tests PASS with 0 failures and 0 errors.

- [ ] **Step 2: Run code-quality and security checks**

Run: `bin/rubocop`

Expected: no offenses.

Run: `bin/brakeman --no-pager`

Expected: 0 security warnings attributable to the homepage implementation.

- [ ] **Step 3: Inspect the page against the visual reference at four widths**

Запустить `bin/rails server`, открыть страницу и сохранить контрольные скриншоты при 1440 × 1000, 1024 × 900, 768 × 900 и 375 × 812. На каждом размере проверить весь документ, а не только первый экран:

- порядок и пропорции секций соответствуют макету;
- нет обрезанного и перекрывающегося текста;
- нет горизонтальной прокрутки;
- состояния hover, focus, active и empty читаемы;
- SVG отображается без потери качества;
- calculator, supplier filters, notices, repeat order и mobile menu работают.

Исправлять найденные дефекты небольшими локальными изменениями и после каждой серии повторять соответствующие automated tests.

- [ ] **Step 4: Add concise README instructions**

Заменить шаблонный README инструкциями для текущего этапа: требования Ruby/Rails, `bin/setup`, `bin/rails server`, адрес главной, команды тестов и перечень демонстрационных функций. Явно указать, что данные не сохраняются и реальные заявки не отправляются.

- [ ] **Step 5: Re-run final verification after documentation and polish**

Run: `bin/rails test && bin/rails test:system && bin/rubocop && bin/brakeman --no-pager`

Expected: every command exits 0; tests report 0 failures and 0 errors; RuboCop reports no offenses; Brakeman reports no new warnings.

- [ ] **Step 6: Commit the reviewed homepage**

```bash
git add README.md app test
git commit -m "docs: document homepage demo"
```
