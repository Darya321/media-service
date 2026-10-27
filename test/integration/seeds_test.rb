require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  SEEDED_MODELS = [
    Category,
    Post,
    Material,
    Supplier,
    SupplierMaterial,
    Subscription,
    Inquiry
  ].freeze

  test "running seeds twice keeps stable record counts" do
    without_admin_credentials do
      Rails.application.load_seed
      first_counts = SEEDED_MODELS.to_h { |model| [ model.name, model.count ] }

      Rails.application.load_seed

      assert_equal first_counts, SEEDED_MODELS.to_h { |model| [ model.name, model.count ] }
      assert_operator Category.count, :>=, 4
      assert_operator Material.count, :>=, 6
      assert_operator Supplier.count, :>=, 6
      assert Post.find_by!(slug: "packaging-for-candles").published?
      assert Post.find_by!(slug: "packaging-trends-2027").published_at.future?
      assert Post.find_by!(slug: "future-material-guide").draft?

      legislation = Category.find_by!(slug: "legislation")
      assert_equal "Законодательство", legislation.name

      partner_post = Post.find_by!(slug: "recycled-cardboard-launch")
      assert partner_post.partner?
      assert_equal "eco-pack-factory", partner_post.supplier.slug
      assert_equal "О компании", partner_post.cta_label

      external_post = Post.find_by!(slug: "small-business-packaging-audit")
      assert external_post.external?
      assert_match %r{\Ahttps://}, external_post.external_url
      assert external_post.valid?

      assert_operator Post.where(category: legislation).publicly_visible.count, :>=, 3
      refute_includes Post.column_names, "views_count"
      refute_includes Post.column_names, "impressions_count"
    end
  end

  test "does not create an administrator without both environment values" do
    without_admin_credentials do
      assert_no_difference -> { Admin.count } do
        Rails.application.load_seed
      end
    end
  end

  test "creates one normalized administrator from environment values" do
    with_environment(
      "ADMIN_EMAIL" => "  Seed.Owner@Example.TEST ",
      "ADMIN_PASSWORD" => "safe-seed-password"
    ) do
      assert_difference -> { Admin.where(email: "seed.owner@example.test").count }, 1 do
        Rails.application.load_seed
      end

      admin = Admin.find_by!(email: "seed.owner@example.test")
      assert admin.authenticate("safe-seed-password")

      assert_no_difference -> { Admin.where(email: "seed.owner@example.test").count } do
        Rails.application.load_seed
      end
    end
  end

  private

  def without_admin_credentials(&block)
    with_environment("ADMIN_EMAIL" => nil, "ADMIN_PASSWORD" => nil, &block)
  end

  def with_environment(values)
    previous = values.to_h { |key, _value| [ key, ENV.key?(key) ? ENV[key] : :missing ] }

    values.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    previous.each do |key, value|
      value == :missing ? ENV.delete(key) : ENV[key] = value
    end
  end
end
