require "test_helper"
require "bcrypt"

class PasswordDependencyTest < ActiveSupport::TestCase
  test "bcrypt creates a digest that verifies the original password" do
    digest = BCrypt::Password.create("teacher-demo-password")

    assert BCrypt::Password.new(digest).is_password?("teacher-demo-password")
    refute BCrypt::Password.new(digest).is_password?("incorrect-password")
  end
end
