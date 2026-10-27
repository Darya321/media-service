module ApplicationHelper
  POST_KIND_LABELS = {
    "article" => "Статья",
    "guide" => "Инструкция",
    "review" => "Обзор",
    "interview" => "Интервью",
    "news" => "Новость"
  }.freeze
  POST_COVER_ASSETS = {
    "cardboard-guide.svg" => "figma/materials-tool-node-206-1169.svg",
    "candle-box-guide.svg" => "figma/material-craft-cardboard.jpeg",
    "cardboard-review.svg" => "figma/material-microcorrugated.jpeg",
    "supplier-brief.svg" => "figma/material-corrugated-cardboard.jpeg",
    "brand-interview.svg" => "figma/material-solid-cardboard.jpeg",
    "material-corrugated-cardboard.jpeg" => "figma/material-corrugated-cardboard.jpeg",
    "material-craft-cardboard.jpeg" => "figma/material-craft-cardboard.jpeg",
    "material-paper.png" => "figma/material-paper.png"
  }.freeze
  POST_FALLBACK_ASSETS = {
    "materials" => "figma/material-microcorrugated.jpeg",
    "production" => "figma/material-solid-cardboard.jpeg",
    "suppliers" => "figma/material-corrugated-cardboard.jpeg",
    "business-cases" => "figma/material-craft-cardboard.jpeg",
    "legislation" => "figma/material-paper.png"
  }.freeze
  RUSSIAN_MONTHS = %w[
    января февраля марта апреля мая июня
    июля августа сентября октября ноября декабря
  ].freeze
  MATERIAL_ASSETS = {
    "craft-cardboard" => "figma/material-craft-cardboard.jpeg",
    "microcorrugated-cardboard" => "figma/material-microcorrugated.jpeg",
    "solid-cardboard" => "figma/material-solid-cardboard.jpeg",
    "corrugated-cardboard" => "figma/material-corrugated-cardboard.jpeg",
    "paper" => "figma/material-paper.png",
    "flexible-film" => "figma/material-flexible-film.jpeg"
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
    POST_COVER_ASSETS[post.cover_asset] || POST_FALLBACK_ASSETS[post.category.slug]
  end

  def post_placement_label(post)
    return "Партнёрский материал" if post.partner?

    "Рекламное предложение" if post.external?
  end

  def post_cta_url(post)
    return supplier_path(post.supplier) if post.partner? && post.supplier&.active?

    post.external_url if post.external? && safe_external_url?(post.external_url)
  end

  def post_external_cta?(post)
    post.external? && post_cta_url(post).present?
  end

  def post_publication_date(post)
    return unless post.published_at?

    date = post.published_at.in_time_zone.to_date
    "#{date.day} #{RUSSIAN_MONTHS.fetch(date.month - 1)} #{date.year}"
  end

  def material_asset(material)
    MATERIAL_ASSETS.fetch(material.slug)
  end

  def score_dots(score, label:)
    content_tag(:div, class: "material-score", aria: { label: "#{label}: #{score} из 5" }) do
      safe_join([
        content_tag(:span, label, class: "material-score__label"),
        content_tag(:span, class: "material-score__track", aria: { hidden: true }) do
          safe_join(5.times.map { |index| content_tag(:i, "", class: (index < score ? "is-filled" : nil)) })
        end,
        content_tag(:span, "#{score} из 5", class: "material-score__value")
      ])
    end
  end

  private

  def safe_external_url?(value)
    uri = URI.parse(value.to_s)
    uri.is_a?(URI::HTTP) && uri.host.present? && %w[http https].include?(uri.scheme)
  rescue URI::InvalidURIError
    false
  end
end
