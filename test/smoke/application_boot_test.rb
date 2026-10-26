require "test_helper"

class ApplicationBootTest < ActiveSupport::TestCase
  test "application boots on the approved Rails release" do
    assert_kind_of Rails::Application, Rails.application
    assert_equal "8.1.4", Rails.version
  end
end
