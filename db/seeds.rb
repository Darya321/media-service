upsert_by = lambda do |model, lookup, attributes|
  record = model.find_or_initialize_by(lookup)
  record.update!(attributes)
  record
end

categories = [
  {
    slug: "materials",
    name: "Материалы",
    description: "Сравниваем свойства картона, бумаги, стекла и других упаковочных материалов."
  },
  {
    slug: "production",
    name: "Производство",
    description: "Объясняем печать, конструирование, тиражи и подготовку макетов."
  },
  {
    slug: "suppliers",
    name: "Поставщики",
    description: "Разбираемся, как выбрать подрядчика и сравнить предложения."
  },
  {
    slug: "business-cases",
    name: "Истории бизнеса",
    description: "Практические истории брендов и производителей упаковки."
  }
].to_h do |attributes|
  category = upsert_by.call(Category, { slug: attributes.fetch(:slug) }, attributes.except(:slug))
  [ attributes.fetch(:slug), category ]
end

materials = [
  {
    slug: "microcorrugated-cardboard",
    name: "Микрогофрокартон",
    summary: "Лёгкий и прочный материал для небольших коробок.",
    description: "Защищает товар при доставке и подходит для аккуратной полноцветной печати.",
    use_cases: "Свечи, косметика, посуда, небольшая электроника",
    strength_score: 4, print_score: 4, eco_score: 4, cost_score: 3, price_factor: 1.0
  },
  {
    slug: "craft-cardboard",
    name: "Крафт-картон",
    summary: "Материал с естественной фактурой для лаконичной упаковки.",
    description: "Подходит брендам с экологичным позиционированием и простой графикой.",
    use_cases: "Косметика, подарки, одежда, чай и кофе",
    strength_score: 3, print_score: 3, eco_score: 5, cost_score: 4, price_factor: 0.9
  },
  {
    slug: "corrugated-cardboard",
    name: "Гофрокартон",
    summary: "Универсальный материал для транспортной упаковки.",
    description: "Выдерживает нагрузку и помогает защитить товары в логистике.",
    use_cases: "Маркетплейсы, техника, наборы товаров, доставка",
    strength_score: 5, print_score: 3, eco_score: 4, cost_score: 5, price_factor: 0.82
  },
  {
    slug: "solid-cardboard",
    name: "Переплётный картон",
    summary: "Плотная основа для премиальных коробок.",
    description: "Используется в жёстких конструкциях с кашировкой и декоративной отделкой.",
    use_cases: "Подарочные наборы, украшения, премиальная косметика",
    strength_score: 5, print_score: 5, eco_score: 3, cost_score: 2, price_factor: 1.45
  },
  {
    slug: "paper",
    name: "Бумага",
    summary: "Доступная основа для пакетов, обёртки и этикеток.",
    description: "Даёт много вариантов печати, плотности и фактуры.",
    use_cases: "Пакеты, этикетки, вкладыши, обёртка",
    strength_score: 2, print_score: 5, eco_score: 5, cost_score: 5, price_factor: 0.68
  },
  {
    slug: "flexible-film",
    name: "Гибкая плёнка",
    summary: "Лёгкая герметичная упаковка для товаров с особыми условиями хранения.",
    description: "Подходит для небольшого веса, барьерной защиты и яркой печати.",
    use_cases: "Косметика, бытовая химия, продукты, пробники",
    strength_score: 3, print_score: 4, eco_score: 2, cost_score: 4, price_factor: 0.76
  }
].to_h do |attributes|
  material = upsert_by.call(Material, { slug: attributes.fetch(:slug) }, attributes.except(:slug))
  [ attributes.fetch(:slug), material ]
end

supplier_rows = [
  {
    slug: "kraft-packaging",
    name: "Крафт упаковка",
    company_type: :factory,
    specialization: "Коробки из картона по индивидуальным размерам",
    description: "Производство небольших и средних тиражей с печатью и вырубкой.",
    minimum_order: 500,
    unit_price_from: 18.5,
    regions: [ "Москва", "Московская область" ],
    services: [ "Конструкция", "Печать", "Вырубка" ],
    contact_email: "hello@kraft.example",
    contact_url: "https://example.test/kraft-packaging",
    promoted: true,
    active: true,
    material_slugs: %w[microcorrugated-cardboard craft-cardboard corrugated-cardboard]
  },
  {
    slug: "ready-box",
    name: "Готовая коробка",
    company_type: :box_supplier,
    specialization: "Коробки стандартных размеров со склада",
    description: "Быстрый вариант для тестовых партий и запуска продаж.",
    minimum_order: 50,
    unit_price_from: 12,
    regions: [ "Москва", "Россия" ],
    services: [ "Подбор размера", "Доставка" ],
    contact_email: "order@readybox.example",
    contact_url: "https://example.test/ready-box",
    promoted: false,
    active: true,
    material_slugs: %w[craft-cardboard corrugated-cardboard]
  },
  {
    slug: "print-line",
    name: "Принт Лайн",
    company_type: :print_shop,
    specialization: "Печать этикеток, пакетов и картонной упаковки",
    description: "Помогает подготовить макет и подобрать технологию печати.",
    minimum_order: 300,
    unit_price_from: 8.5,
    regions: [ "Москва", "Санкт-Петербург" ],
    services: [ "Цифровая печать", "Офсет", "Ламинация" ],
    contact_email: "hello@printline.example",
    contact_url: "https://example.test/print-line",
    promoted: false,
    active: true,
    material_slugs: %w[paper craft-cardboard solid-cardboard]
  },
  {
    slug: "form-design",
    name: "Форма и смысл",
    company_type: :design_studio,
    specialization: "Айдентика и дизайн упаковки",
    description: "Разрабатывает визуальную концепцию и готовит макеты к производству.",
    minimum_order: 0,
    unit_price_from: 0,
    regions: [ "Россия", "Онлайн" ],
    services: [ "Брендинг", "Дизайн", "Предпечатная подготовка" ],
    contact_email: "brief@form.example",
    contact_url: "https://example.test/form-design",
    promoted: false,
    active: true,
    material_slugs: %w[paper craft-cardboard solid-cardboard flexible-film]
  },
  {
    slug: "fulfill-now",
    name: "Фулфил сейчас",
    company_type: :fulfillment,
    specialization: "Комплектация и упаковка заказов маркетплейсов",
    description: "Хранит товары, собирает заказы и готовит их к отгрузке.",
    minimum_order: 100,
    unit_price_from: 22,
    regions: [ "Москва", "Казань" ],
    services: [ "Хранение", "Комплектация", "Маркировка" ],
    contact_email: "team@fulfill.example",
    contact_url: "https://example.test/fulfill-now",
    promoted: false,
    active: true,
    material_slugs: %w[corrugated-cardboard microcorrugated-cardboard flexible-film]
  },
  {
    slug: "eco-pack-factory",
    name: "Эко Пак Фабрика",
    company_type: :factory,
    specialization: "Бумажная и картонная упаковка",
    description: "Производит упаковку из перерабатываемых материалов и помогает оптимизировать конструкцию.",
    minimum_order: 1_000,
    unit_price_from: 15,
    regions: [ "Санкт-Петербург", "Россия" ],
    services: [ "Конструкция", "Флексопечать", "Доставка" ],
    contact_email: "sales@ecopack.example",
    contact_url: "https://example.test/eco-pack-factory",
    promoted: true,
    active: true,
    material_slugs: %w[paper craft-cardboard corrugated-cardboard]
  }
]

suppliers = supplier_rows.to_h do |attributes|
  supplier = upsert_by.call(
    Supplier,
    { slug: attributes.fetch(:slug) },
    attributes.except(:slug, :material_slugs)
  )
  supplier.materials = attributes.fetch(:material_slugs).map { |slug| materials.fetch(slug) }
  [ attributes.fetch(:slug), supplier ]
end

post_rows = [
  {
    slug: "packaging-for-candles",
    category: categories.fetch("materials"),
    title: "Как выбрать упаковку для свечей",
    summary: "Сравниваем материалы, защиту от ударов и стоимость небольшого тиража.",
    body: "Начните с размеров свечи и вкладыша. Для стеклянной банки важна фиксация внутри коробки. Микрогофрокартон подходит для доставки, а плотный картон — для подарочной подачи.",
    kind: :guide,
    status: :published,
    published_at: 14.days.ago,
    featured: true,
    cover_asset: "candle-box-guide.svg"
  },
  {
    slug: "microcorrugated-overview",
    category: categories.fetch("materials"),
    title: "Крафт и микрогофрокартон: что подойдёт вашему товару",
    summary: "Практическое сравнение двух популярных материалов.",
    body: "Крафт-картон выигрывает по естественной фактуре, а микрогофрокартон лучше защищает товар. Выбор зависит от логистики, веса и того, какую печать вы планируете.",
    kind: :review,
    status: :published,
    published_at: 10.days.ago,
    featured: true,
    cover_asset: "cardboard-review.svg"
  },
  {
    slug: "supplier-brief",
    category: categories.fetch("suppliers"),
    title: "Как составить понятный запрос поставщику",
    summary: "Список параметров, которые помогают быстрее получить сравнимые предложения.",
    body: "Укажите товар, размеры, вес, тираж, материал, печать, регион и желаемый срок. Приложите макет, если он уже готов, и отдельно отметьте обязательные требования.",
    kind: :article,
    status: :published,
    published_at: 7.days.ago,
    featured: false,
    cover_asset: "supplier-brief.svg"
  },
  {
    slug: "small-brand-interview",
    category: categories.fetch("business-cases"),
    title: "Интервью с небольшим брендом косметики",
    summary: "Как команда тестировала упаковку и сокращала первый тираж.",
    body: "Бренд начал со стандартной коробки и одной этикетки, а индивидуальную конструкцию заказал после проверки спроса. Такой подход помог не замораживать бюджет на старте.",
    kind: :interview,
    status: :published,
    published_at: 4.days.ago,
    featured: false,
    cover_asset: "brand-interview.svg"
  },
  {
    slug: "packaging-trends-2027",
    category: categories.fetch("production"),
    title: "Тренды упаковки 2027 года",
    summary: "Запланированная новость о новых материалах и требованиях рынка.",
    body: "Материал появится на сайте в дату публикации.",
    kind: :news,
    status: :published,
    published_at: 30.days.from_now,
    featured: false,
    cover_asset: nil
  },
  {
    slug: "future-material-guide",
    category: categories.fetch("materials"),
    title: "Черновик новой инструкции по материалам",
    summary: "Редакционный черновик, который не должен быть виден публично.",
    body: "Рабочий текст будущей инструкции.",
    kind: :guide,
    status: :draft,
    published_at: nil,
    featured: false,
    cover_asset: nil
  }
]

post_rows.each do |attributes|
  upsert_by.call(Post, { slug: attributes.fetch(:slug) }, attributes.except(:slug))
end

upsert_by.call(Subscription, { email: "demo-reader@example.test" }, {})

upsert_by.call(
  Inquiry,
  { email: "demo-buyer@example.test", product_type: "Свечи в стекле" },
  {
    supplier: suppliers.fetch("kraft-packaging"),
    material: materials.fetch("microcorrugated-cardboard"),
    length_mm: 90,
    width_mm: 90,
    height_mm: 110,
    weight_grams: 320,
    fragile: true,
    quantity: 500,
    budget: 12_000,
    deadline: 21.days.from_now.to_date,
    region: "Москва",
    print_option: "none",
    extras: [],
    estimated_unit_price: 24,
    estimated_total_price: 12_000,
    estimated_low_price: 10_800,
    estimated_high_price: 13_200,
    status: :submitted
  }
)

admin_email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
admin_password = ENV["ADMIN_PASSWORD"].to_s

if admin_email.present? && admin_password.present?
  admin = Admin.find_or_initialize_by(email: admin_email)
  admin.password = admin_password
  admin.password_confirmation = admin_password
  admin.save!
end
