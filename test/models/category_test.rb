require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "requires a unique name and slug" do
    category = Category.new(name: "", slug: "")

    refute category.valid?
    assert_includes category.errors[:name], "can't be blank"

    duplicate = Category.new(name: categories(:materials).name, slug: categories(:materials).slug)

    refute duplicate.valid?
    assert duplicate.errors[:name].any?
    assert duplicate.errors[:slug].any?
  end

  test "generates a slug once and uses it in URLs" do
    category = Category.new(name: "Eco Packaging")

    assert category.valid?
    assert_equal "eco-packaging", category.slug
    assert_equal "eco-packaging", category.to_param

    category.name = "Renamed Packaging"
    category.validate

    assert_equal "eco-packaging", category.slug
  end

  test "cannot be destroyed while posts belong to it" do
    category = categories(:materials)

    refute category.destroy
    assert_includes category.errors[:base], "Cannot delete record because dependent posts exist"
  end
end
