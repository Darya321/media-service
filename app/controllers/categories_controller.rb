class CategoriesController < ApplicationController
  def show
    @category = Category.find_by!(slug: params[:slug])
    @posts = Post.publicly_visible
      .where(category: @category)
      .includes(:category)
      .order(featured: :desc, published_at: :desc, title: :asc)
  end
end
