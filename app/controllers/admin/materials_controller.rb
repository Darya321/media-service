class Admin::MaterialsController < Admin::BaseController
  before_action :set_material, only: %i[show edit update destroy]

  def index
    @materials = Material.order(:name)
  end

  def show
  end

  def new
    @material = Material.new(
      strength_score: 3,
      print_score: 3,
      eco_score: 3,
      cost_score: 3,
      price_factor: 1
    )
  end

  def create
    @material = Material.new(material_params)
    if @material.save
      redirect_to admin_material_path(@material), notice: "Материал создан"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @material.update(material_params)
      redirect_to admin_material_path(@material), notice: "Материал обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @material.destroy
      redirect_to admin_materials_path, notice: "Материал удалён"
    else
      redirect_to admin_material_path(@material), alert: "Материал нельзя удалить, пока он используется в заявках"
    end
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_material_path(@material), alert: "Материал нельзя удалить, пока он используется в заявках"
  end

  private

  def set_material
    @material = Material.find_by!(slug: params[:id])
  end

  def material_params
    params.require(:material).permit(
      :name,
      :slug,
      :summary,
      :description,
      :use_cases,
      :strength_score,
      :print_score,
      :eco_score,
      :cost_score,
      :price_factor
    )
  end
end
