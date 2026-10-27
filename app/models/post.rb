require "uri"

class Post < ApplicationRecord
  include HasSlug

  belongs_to :category
  belongs_to :supplier, optional: true

  enum :kind, {
    article: 0,
    guide: 1,
    review: 2,
    interview: 3,
    news: 4
  }

  enum :status, {
    draft: 0,
    published: 1
  }

  enum :placement, {
    editorial: 0,
    partner: 1,
    external: 2
  }

  validates :title, :summary, :body, presence: true
  validates :supplier, presence: true, if: :partner?
  validates :external_url, presence: true, if: :external?
  validate :external_url_uses_web_scheme, if: -> { external? && external_url.present? }

  scope :publicly_visible, -> {
    published.where("published_at IS NULL OR published_at <= ?", Time.current)
  }
  scope :promotable, -> {
    where(
      "(posts.placement = :partner AND posts.supplier_id IS NOT NULL) OR " \
        "(posts.placement = :external AND posts.external_url IS NOT NULL AND posts.external_url != '')",
      partner: placements.fetch(:partner),
      external: placements.fetch(:external)
    )
  }

  def slug_source
    title
  end

  private

  def external_url_uses_web_scheme
    uri = URI.parse(external_url)
    return if uri.is_a?(URI::HTTP) && uri.host.present? && %w[http https].include?(uri.scheme)

    errors.add(:external_url, "должен начинаться с http:// или https://")
  rescue URI::InvalidURIError
    errors.add(:external_url, "имеет неверный формат")
  end
end
