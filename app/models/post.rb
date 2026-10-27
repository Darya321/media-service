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
  validate :partner_supplier_is_active, if: -> { partner? && supplier.present? }
  validate :external_url_uses_web_scheme, if: -> { external? && external_url.present? }

  scope :publicly_visible, -> {
    published.where("published_at IS NULL OR published_at <= ?", Time.current)
  }
  scope :promotable, -> {
    left_outer_joins(:supplier).where(
      "(posts.placement = :partner AND suppliers.active = :active) OR " \
        "(posts.placement = :external AND " \
        "(posts.external_url LIKE 'http://%' OR posts.external_url LIKE 'https://%'))",
      partner: placements.fetch(:partner),
      external: placements.fetch(:external),
      active: true
    )
  }
  scope :search_for, ->(query) {
    term = query.to_s.strip.downcase
    next all if term.blank?

    matching_ids = filter_map do |post|
      searchable_text = [ post.title, post.summary, post.body ].join(" ").downcase
      post.id if searchable_text.include?(term)
    end

    where(id: matching_ids)
  }

  def slug_source
    title
  end

  private

  def partner_supplier_is_active
    errors.add(:supplier, "должен быть активен") unless supplier.active?
  end

  def external_url_uses_web_scheme
    uri = URI.parse(external_url)
    return if uri.is_a?(URI::HTTP) && uri.host.present? && %w[http https].include?(uri.scheme)

    errors.add(:external_url, "должен начинаться с http:// или https://")
  rescue URI::InvalidURIError
    errors.add(:external_url, "имеет неверный формат")
  end
end
