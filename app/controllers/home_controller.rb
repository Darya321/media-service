class HomeController < ApplicationController
  def show
    @materials = Material.where(slug: %w[craft-cardboard corrugated-cardboard microcorrugated-cardboard]).order(:name)
    @suppliers = Supplier.available.includes(:materials).order(promoted: :desc, name: :asc).limit(3)
    @posts = Post.publicly_visible.includes(:category).order(featured: :desc, published_at: :desc).limit(3)
    @calculator_values = CalculatorController::DEFAULTS
    @reference_result = PackagingEstimator.call(
      **@calculator_values.slice(
        :product_type, :length_mm, :width_mm, :height_mm, :weight_grams,
        :fragile, :quantity, :region, :print_option, :extras
      ).merge(material: Material.find_by!(slug: @calculator_values[:material_slug]))
    )
    @subscription = Subscription.new
  end
end
