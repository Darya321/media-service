class Admin::SuppliersController < Admin::BaseController
  before_action :set_supplier, only: %i[show edit update destroy]
  before_action :load_materials, only: %i[new create edit update]

  def index
    @suppliers = Supplier.includes(:materials).order(active: :desc, promoted: :desc, name: :asc)
  end

  def show
  end

  def new
    @supplier = Supplier.new(active: true)
  end

  def create
    @supplier = Supplier.new
    assign_supplier_attributes

    if @supplier.save
      redirect_to admin_supplier_path(@supplier), notice: "Поставщик создан"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    assign_supplier_attributes

    if @supplier.save
      redirect_to admin_supplier_path(@supplier), notice: "Поставщик обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @supplier.destroy!
    redirect_to admin_suppliers_path, notice: "Поставщик удалён"
  end

  private

  def set_supplier
    @supplier = Supplier.find_by!(slug: params[:id])
  end

  def load_materials
    @materials = Material.order(:name)
  end

  def assign_supplier_attributes
    attributes = supplier_params.to_h
    attributes["regions"] = normalized_list(attributes.delete("regions_text"))
    attributes["services"] = normalized_list(attributes.delete("services_text"))
    @supplier.assign_attributes(attributes)
  end

  def normalized_list(value)
    value.to_s.split(/[\n,]+/).map(&:strip).reject(&:blank?).uniq
  end

  def supplier_params
    params.require(:supplier).permit(
      :name,
      :slug,
      :company_type,
      :specialization,
      :description,
      :minimum_order,
      :unit_price_from,
      :regions_text,
      :services_text,
      :contact_email,
      :contact_url,
      :promoted,
      :active,
      material_ids: []
    )
  end
end
