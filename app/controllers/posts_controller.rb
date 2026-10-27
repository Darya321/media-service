class PostsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @selected_category = Category.find_by(slug: params[:category]) if params[:category].present?
    @posts = Post.publicly_visible.includes(:category)
    @posts = @posts.where(category: @selected_category) if @selected_category
    @posts = @posts.order(featured: :desc, published_at: :desc, title: :asc)
  end

  def show
    @post = Post.publicly_visible.includes(:category).find_by!(slug: params[:slug])
    @related_posts = Post.publicly_visible
      .where(category: @post.category)
      .where.not(id: @post.id)
      .order(featured: :desc, published_at: :desc)
      .limit(3)
  end
end
