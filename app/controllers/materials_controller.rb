class MaterialsController < ApplicationController
  def index
    @materials = Material.order(:name).to_a
    if params[:use_case].present?
      query = params[:use_case].to_s.strip.downcase
      @materials.select! { |material| material.use_cases.downcase.include?(query) }
    end
  end

  def show
    @material = Material.includes(:suppliers).find_by!(slug: params[:slug])
    @suppliers = @material.suppliers.available.order(promoted: :desc, name: :asc)
  end
end
