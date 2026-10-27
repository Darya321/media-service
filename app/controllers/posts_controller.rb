class PostsController < ApplicationController
  MEDIA_CATEGORY_SLUGS = %w[materials suppliers business-cases legislation].freeze

  def index
    categories_by_slug = Category.where(slug: MEDIA_CATEGORY_SLUGS).index_by(&:slug)
    @media_categories = MEDIA_CATEGORY_SLUGS.filter_map { |slug| categories_by_slug[slug] }
    @categories = @media_categories
    @query = params[:q].to_s.strip
    category_slug = params[:category].to_s.presence
    @selected_category = categories_by_slug[category_slug]
    @filtering = @query.present? || category_slug.present?

    visible_posts = ordered_posts(Post.publicly_visible.includes(:category, :supplier))
    @hero_post = visible_posts.find_by(featured: true) || visible_posts.first

    @posts = if category_slug.present? && @selected_category.nil?
      visible_posts.none
    else
      selected_posts = @selected_category ? visible_posts.where(category: @selected_category) : visible_posts
      selected_posts.search_for(@query)
    end

    @supplier_posts = section_posts(visible_posts, categories_by_slug["suppliers"])
    @legislation_posts = section_posts(visible_posts, categories_by_slug["legislation"])
    @business_feature = section_posts(
      visible_posts.promotable,
      categories_by_slug["business-cases"],
      limit: 1
    ).first
    @subscription = Subscription.new
  end

  def show
    @post = Post.publicly_visible.includes(:category).find_by!(slug: params[:slug])
    @related_posts = Post.publicly_visible
      .where(category: @post.category)
      .where.not(id: @post.id)
      .order(featured: :desc, published_at: :desc)
      .limit(3)
  end

  private

  def ordered_posts(scope)
    scope.order(featured: :desc, published_at: :desc, title: :asc)
  end

  def section_posts(scope, category, limit: 3)
    return scope.none unless category

    scope.where(category: category).limit(limit)
  end
end
