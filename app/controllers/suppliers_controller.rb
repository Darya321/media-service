class SuppliersController < ApplicationController
  COMPANY_TYPE_LABELS = {
    "factory" => "Фабрика",
    "box_supplier" => "Поставщик коробок",
    "print_shop" => "Типография",
    "design_studio" => "Студия дизайна",
    "fulfillment" => "Фулфилмент"
  }.freeze

  def index
    @materials = Material.order(:name)
    @suppliers = filtered_suppliers.includes(:materials).order(promoted: :desc, name: :asc)
  end

  def show
    @supplier = Supplier.available.includes(:materials).find_by!(slug: params[:slug])
  end

  private

  def filtered_suppliers
    suppliers = Supplier.available
    suppliers = suppliers.where(company_type: params[:company_type]) if Supplier.company_types.key?(params[:company_type])
    suppliers = suppliers.joins(:materials).where(materials: { slug: params[:material] }) if params[:material].present?
    if params[:region].present?
      region = ActiveRecord::Base.sanitize_sql_like(params[:region].strip)
      suppliers = suppliers.where("suppliers.regions LIKE ?", "%\"#{region}\"%")
    end
    suppliers.distinct
  end
end
