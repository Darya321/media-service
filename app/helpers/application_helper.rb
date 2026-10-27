module ApplicationHelper
  POST_KIND_LABELS = {
    "article" => "Статья",
    "guide" => "Инструкция",
    "review" => "Обзор",
    "interview" => "Интервью",
    "news" => "Новость"
  }.freeze
  POST_COVER_ASSETS = {
    "cardboard-guide.svg" => "figma/materials-tool-node-206-1169.svg"
  }.freeze

  def nav_link_to(label, path, **options)
    active = current_page?(path)
    classes = [ options.delete(:class), "site-nav__link", ("is-active" if active) ].compact

    link_to label, path, **options.merge(class: classes, aria: (active ? { current: "page" } : nil))
  end

  def post_kind_label(kind)
    POST_KIND_LABELS.fetch(kind.to_s, kind.to_s.humanize)
  end

  def post_cover_asset(post)
    POST_COVER_ASSETS[post.cover_asset]
  end
end
