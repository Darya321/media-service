class CalculatorController < ApplicationController
  DISCLAIMER = "Расчёт предварительный — точную цену и условия назовёт выбранная компания.".freeze
  DEFAULTS = {
    product_type: "Свечи в стекле",
    length_mm: 90,
    width_mm: 90,
    height_mm: 110,
    weight_grams: 0,
    fragile: "false",
    material_slug: "microcorrugated-cardboard",
    quantity: 500,
    budget: "",
    deadline: "",
    region: "Москва",
    print_option: "none",
    extras: []
  }.freeze

  def show
    prepare_page(DEFAULTS.merge(query_defaults))
    @result = build_estimate(@calculator_values)
  rescue PackagingEstimator::InvalidInput
    @result = nil
  end

  def estimate
    prepare_page(DEFAULTS.merge(calculator_params.to_h.symbolize_keys))
    @result = build_estimate(@calculator_values)

    respond_to do |format|
      format.json { render json: result_payload(@result) }
      format.html { render :show }
    end
  rescue PackagingEstimator::InvalidInput => error
    respond_to do |format|
      format.json { render json: { errors: error.errors }, status: :unprocessable_entity }
      format.html do
        @calculator_errors = error.errors
        @result = nil
        render :show, status: :unprocessable_entity
      end
    end
  end

  private

  def prepare_page(values)
    @materials = Material.order(:name)
    @calculator_values = values
  end

  def query_defaults
    params.permit(:product_type, :length_mm, :width_mm, :height_mm, :weight_grams,
      :fragile, :material_slug, :quantity, :budget, :deadline, :region, :print_option,
      extras: []).to_h.symbolize_keys
  end

  def calculator_params
    params.permit(:product_type, :length_mm, :width_mm, :height_mm, :weight_grams,
      :fragile, :material_slug, :quantity, :budget, :deadline, :region, :print_option,
      extras: [])
  end

  def build_estimate(values)
    material = Material.find_by(slug: values[:material_slug])
    raise PackagingEstimator::InvalidInput.new(material: [ "Выберите материал из списка" ]) unless material

    PackagingEstimator.call(
      product_type: values[:product_type],
      length_mm: values[:length_mm],
      width_mm: values[:width_mm],
      height_mm: values[:height_mm],
      weight_grams: values[:weight_grams],
      fragile: values[:fragile],
      material: material,
      quantity: values[:quantity],
      region: values[:region],
      print_option: values[:print_option],
      extras: values[:extras]
    )
  end

  def result_payload(result)
    {
      unit_price: result.unit_price.to_f,
      total_price: result.total_price.to_f,
      low_price: result.low_price.to_f,
      high_price: result.high_price.to_f,
      breakdown: result.breakdown.transform_values(&:to_f),
      disclaimer: DISCLAIMER
    }
  end
end
