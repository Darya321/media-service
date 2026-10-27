class InquiriesController < ApplicationController
  FORM_DEFAULTS = CalculatorController::DEFAULTS.merge(email: "", supplier_id: nil).freeze

  def new
    prepare_form(FORM_DEFAULTS.merge(inquiry_query_params.to_h.symbolize_keys))
  end

  def create
    values = FORM_DEFAULTS.merge(inquiry_params.to_h.symbolize_keys)
    prepare_form(values)
    assign_relations(values)

    if @inquiry.errors.empty? && @inquiry.valid?
      estimate = PackagingEstimator.call(**@inquiry.calculator_attributes)
      assign_estimate(estimate)
      @inquiry.save!
      render :create, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  rescue PackagingEstimator::InvalidInput => error
    error.errors.each do |attribute, messages|
      Array(messages).each { |message| @inquiry.errors.add(attribute, message) }
    end
    render :new, status: :unprocessable_entity
  end

  private

  def prepare_form(values)
    @materials = Material.order(:name)
    @form_values = values
    @inquiry = Inquiry.new(inquiry_attributes(values))
    @supplier = active_supplier(values[:supplier_id])
    @inquiry.supplier = @supplier
  end

  def assign_relations(values)
    material = Material.find_by(slug: values[:material_slug])
    if material
      @inquiry.material = material
    else
      @inquiry.errors.add(:material, "выберите материал из списка")
    end

    return if values[:supplier_id].blank?

    if @supplier
      @inquiry.supplier = @supplier
    else
      @inquiry.errors.add(:supplier, "выберите активного поставщика")
    end
  end

  def active_supplier(id)
    return if id.blank?

    Supplier.available.find_by(id: id)
  end

  def inquiry_attributes(values)
    values.slice(
      :email, :product_type, :length_mm, :width_mm, :height_mm, :weight_grams,
      :fragile, :quantity, :budget, :deadline, :region, :print_option, :extras
    )
  end

  def assign_estimate(result)
    @inquiry.assign_attributes(
      estimated_unit_price: result.unit_price,
      estimated_total_price: result.total_price,
      estimated_low_price: result.low_price,
      estimated_high_price: result.high_price
    )
  end

  def inquiry_query_params
    params.permit(
      :email, :supplier_id, :product_type, :length_mm, :width_mm, :height_mm,
      :weight_grams, :fragile, :material_slug, :quantity, :budget, :deadline,
      :region, :print_option, extras: []
    )
  end

  def inquiry_params
    params.require(:inquiry).permit(
      :email, :supplier_id, :product_type, :length_mm, :width_mm, :height_mm,
      :weight_grams, :fragile, :material_slug, :quantity, :budget, :deadline,
      :region, :print_option, extras: []
    )
  end
end
