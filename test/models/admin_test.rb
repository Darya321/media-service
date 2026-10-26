require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "normalizes email and requires it to be unique" do
    admin = Admin.new(
      email: "  New.Admin@Example.COM ",
      password: "long-enough-password",
      password_confirmation: "long-enough-password"
    )

    assert admin.valid?
    assert_equal "new.admin@example.com", admin.email

    duplicate = Admin.new(
      email: " OWNER@EXAMPLE.TEST ",
      password: "long-enough-password",
      password_confirmation: "long-enough-password"
    )

    refute duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "requires a password of at least twelve characters" do
    admin = Admin.new(email: "short@example.test", password: "short", password_confirmation: "short")

    refute admin.valid?
    assert admin.errors[:password].any?
  end

  test "rejects a malformed account email" do
    admin = Admin.new(
      email: "owner@invalid",
      password: "long-enough-password",
      password_confirmation: "long-enough-password"
    )

    refute admin.valid?
    assert admin.errors[:email].any?
  end

  test "stores a digest and authenticates only the correct password" do
    admin = admins(:owner)

    refute_equal "correct-horse-battery", admin.password_digest
    assert_equal admin, admin.authenticate("correct-horse-battery")
    refute admin.authenticate("wrong-password")
  end
end
