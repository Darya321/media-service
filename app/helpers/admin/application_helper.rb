module Admin::ApplicationHelper
  POST_KIND_LABELS = {
    "article" => "Статья",
    "guide" => "Инструкция",
    "review" => "Обзор",
    "interview" => "Интервью",
    "news" => "Новость"
  }.freeze

  POST_STATUS_LABELS = {
    "draft" => "Черновик",
    "published" => "Опубликовано"
  }.freeze

  SUPPLIER_TYPE_LABELS = {
    "factory" => "Фабрика",
    "box_supplier" => "Поставщик коробок",
    "print_shop" => "Типография",
    "design_studio" => "Студия дизайна",
    "fulfillment" => "Фулфилмент"
  }.freeze

  INQUIRY_STATUS_LABELS = {
    "submitted" => "Новая",
    "reviewing" => "На рассмотрении",
    "contacted" => "Связались",
    "closed" => "Закрыта"
  }.freeze

  def admin_nav_class(path)
    "admin-nav__link#{' admin-nav__link--active' if current_page?(path)}"
  end

  def admin_post_kind_options
    POST_KIND_LABELS.map { |value, label| [ label, value ] }
  end

  def admin_post_status_options
    POST_STATUS_LABELS.map { |value, label| [ label, value ] }
  end

  def admin_post_kind_label(post)
    POST_KIND_LABELS.fetch(post.kind)
  end

  def admin_post_status_label(post)
    POST_STATUS_LABELS.fetch(post.status)
  end

  def admin_supplier_type_options
    SUPPLIER_TYPE_LABELS.map { |value, label| [ label, value ] }
  end

  def admin_supplier_type_label(supplier)
    SUPPLIER_TYPE_LABELS.fetch(supplier.company_type)
  end

  def admin_inquiry_status_options
    INQUIRY_STATUS_LABELS.map { |value, label| [ label, value ] }
  end

  def admin_inquiry_status_label(inquiry)
    INQUIRY_STATUS_LABELS.fetch(inquiry.status)
  end
end
