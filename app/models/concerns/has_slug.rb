module HasSlug
  extend ActiveSupport::Concern

  included do
    before_validation :set_slug, if: -> { slug.blank? }
    before_validation :normalize_slug, if: :will_save_change_to_slug?

    validates :slug,
      presence: true,
      uniqueness: { case_sensitive: false },
      format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  end

  def to_param
    slug.presence || super
  end

  private

  def set_slug
    self.slug = slug_source
  end

  def normalize_slug
    self.slug = slug.to_s.parameterize
  end
end
