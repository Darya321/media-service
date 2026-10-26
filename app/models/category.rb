class Category < ApplicationRecord
  include HasSlug

  has_many :posts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def slug_source
    name
  end
end
