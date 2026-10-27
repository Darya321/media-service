require "bigdecimal"

class PackagingEstimator
  Result = Data.define(:unit_price, :total_price, :low_price, :high_price, :breakdown)

  class InvalidInput < ArgumentError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super("Calculator input is invalid")
    end
  end

  REFERENCE_SURFACE_MM2 = BigDecimal("55800")
  REFERENCE_UNIT_PRICE = BigDecimal("24")
  MAX_DIMENSION_MM = 5_000
  MAX_WEIGHT_GRAMS = 100_000
  MAX_QUANTITY = 1_000_000
  PRINT_FACTORS = {
    "none" => BigDecimal("1"),
    "one_color" => BigDecimal("1.08"),
    "full_color" => BigDecimal("1.18")
  }.freeze
  EXTRA_FACTORS = {
    "insert" => BigDecimal("0.08"),
    "window" => BigDecimal("0.06"),
    "varnish" => BigDecimal("0.05")
  }.freeze

  def self.call(**attributes)
    new(**attributes).call
  end

  def initialize(product_type:, length_mm:, width_mm:, height_mm:, weight_grams:, fragile:,
    material:, quantity:, region:, print_option:, extras:)
    @product_type = product_type.to_s.strip
    @length_mm = integer_or_nil(length_mm)
    @width_mm = integer_or_nil(width_mm)
    @height_mm = integer_or_nil(height_mm)
    @weight_grams = integer_or_nil(weight_grams)
    @fragile = ActiveModel::Type::Boolean.new.cast(fragile)
    @material = material
    @quantity = integer_or_nil(quantity)
    @region = region.to_s.strip
    @print_option = print_option.to_s
    @extras = Array(extras).reject(&:blank?).map(&:to_s).uniq.sort
  end

  def call
    validate!

    unit_price = calculate_unit_price.round(2)
    total_price = (unit_price * quantity).round(2)

    Result.new(
      unit_price: unit_price,
      total_price: total_price,
      low_price: (unit_price * BigDecimal("0.88")).round(2),
      high_price: (unit_price * BigDecimal("1.17")).round(2),
      breakdown: breakdown_for(unit_price)
    )
  end

  private

  attr_reader :product_type, :length_mm, :width_mm, :height_mm, :weight_grams,
    :fragile, :material, :quantity, :region, :print_option, :extras

  def validate!
    errors = {}
    errors[:product_type] = [ "Опишите товар" ] if product_type.blank?
    validate_integer(errors, :length_mm, length_mm, 1..MAX_DIMENSION_MM)
    validate_integer(errors, :width_mm, width_mm, 1..MAX_DIMENSION_MM)
    validate_integer(errors, :height_mm, height_mm, 1..MAX_DIMENSION_MM)
    validate_integer(errors, :weight_grams, weight_grams, 0..MAX_WEIGHT_GRAMS)
    validate_integer(errors, :quantity, quantity, 1..MAX_QUANTITY)
    errors[:region] = [ "Выберите регион" ] if region.blank?
    errors[:material] = [ "Выберите материал из списка" ] unless material.is_a?(Material) && material.price_factor.to_d.positive?
    errors[:print_option] = [ "Выберите вариант печати" ] unless PRINT_FACTORS.key?(print_option)

    unknown_extras = extras - EXTRA_FACTORS.keys
    errors[:extras] = [ "Выберите дополнительные опции из списка" ] if unknown_extras.any?

    raise InvalidInput, errors if errors.any?
  end

  def validate_integer(errors, name, value, range)
    return if value.is_a?(Integer) && range.cover?(value)

    errors[name] = [ "Введите число от #{range.begin} до #{range.end}" ]
  end

  def calculate_unit_price
    REFERENCE_UNIT_PRICE *
      size_factor *
      material.price_factor.to_d *
      quantity_factor *
      product_factor *
      region_factor *
      weight_factor *
      (fragile ? BigDecimal("1.12") : BigDecimal("1")) *
      PRINT_FACTORS.fetch(print_option) *
      (BigDecimal("1") + extras.sum { |extra| EXTRA_FACTORS.fetch(extra) })
  end

  def surface_mm2
    BigDecimal((2 * ((length_mm * width_mm) + (length_mm * height_mm) + (width_mm * height_mm))).to_s)
  end

  def size_factor
    factor = surface_mm2 / REFERENCE_SURFACE_MM2
    [ [ factor, BigDecimal("0.45") ].max, BigDecimal("4") ].min
  end

  def quantity_factor
    case quantity
    when 1..100 then BigDecimal("1.35")
    when 101..300 then BigDecimal("1.15")
    when 301..500 then BigDecimal("1")
    when 501..1_000 then BigDecimal("0.92")
    else BigDecimal("0.85")
    end
  end

  def product_factor
    normalized = product_type.downcase
    return BigDecimal("1") if normalized.include?("свеч")
    return BigDecimal("0.92") if normalized.include?("космет")
    return BigDecimal("0.85") if normalized.include?("одеж")

    BigDecimal("1.05")
  end

  def region_factor
    normalized = region.downcase
    return BigDecimal("1") if normalized == "москва"
    return BigDecimal("1.03") if normalized.include?("санкт") || normalized == "спб"

    BigDecimal("1.08")
  end

  def weight_factor
    return BigDecimal("1") if weight_grams <= 500

    surcharge = BigDecimal((weight_grams - 500).to_s) / BigDecimal("50000")
    BigDecimal("1") + [ surcharge, BigDecimal("0.35") ].min
  end

  def breakdown_for(unit_price)
    shares = {
      material: BigDecimal("0.46"),
      printing: BigDecimal("0.12"),
      assembly: BigDecimal("0.18"),
      delivery: BigDecimal("0.12")
    }
    breakdown = shares.transform_values { |share| (unit_price * share).round(2) }
    breakdown[:waste] = unit_price - breakdown.values.sum
    breakdown
  end

  def integer_or_nil(value)
    Integer(value, exception: false)
  end
end
