require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "normalizes whitespace and case before validation" do
    subscription = Subscription.new(email: "  Reader+News@Example.COM ")

    assert subscription.valid?
    assert_equal "reader+news@example.com", subscription.email
  end

  test "requires a valid email" do
    [ nil, "", "not-an-email", "missing@domain" ].each do |email|
      subscription = Subscription.new(email: email)

      refute subscription.valid?, "expected #{email.inspect} to be invalid"
      assert subscription.errors[:email].any?
    end
  end

  test "rejects duplicates after normalization" do
    duplicate = Subscription.new(email: "  READER@example.test ")

    refute duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "database unique index rejects a duplicate email" do
    duplicate = Subscription.new(email: subscriptions(:reader).email)

    assert_raises ActiveRecord::RecordNotUnique do
      duplicate.save!(validate: false)
    end
  end
end
