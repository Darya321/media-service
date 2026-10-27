class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :load_form_options, only: %i[new create edit update]

  def index
    @posts = Post.includes(:category, :supplier).order(created_at: :desc)
  end

  def show
  end

  def new
    @post = Post.new(status: :draft, kind: :article)
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to admin_post_path(@post), notice: "Публикация создана"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: "Публикация обновлена"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to admin_posts_path, notice: "Публикация удалена"
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:id])
  end

  def load_form_options
    @categories = Category.order(:name)
    @suppliers = Supplier.available.order(:name)
  end

  def post_params
    params.require(:post).permit(
      :category_id,
      :title,
      :slug,
      :summary,
      :body,
      :kind,
      :status,
      :published_at,
      :featured,
      :cover_asset,
      :supplier_id,
      :placement,
      :cta_label,
      :external_url
    )
  end
end
