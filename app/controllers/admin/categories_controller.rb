class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @categories = Category.includes(:posts).order(:name)
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_category_path(@category), notice: "Категория создана"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: "Категория обновлена"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Категория удалена"
    else
      redirect_to admin_category_path(@category), alert: "Категорию нельзя удалить, пока в ней есть публикации"
    end
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_category_path(@category), alert: "Категорию нельзя удалить, пока в ней есть публикации"
  end

  private

  def set_category
    @category = Category.find_by!(slug: params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :slug, :description)
  end
end
