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
    POST_COVER_ASSETS[post.cover_asset]
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
end
