class Post < ApplicationRecord
  include HasSlug

  belongs_to :category

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

  validates :title, :summary, :body, presence: true

  scope :publicly_visible, -> {
    published.where("published_at IS NULL OR published_at <= ?", Time.current)
  }

  def slug_source
    title
  end
end
