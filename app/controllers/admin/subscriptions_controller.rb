class Admin::SubscriptionsController < Admin::BaseController
  def index
    @subscriptions = Subscription.order(created_at: :desc)
  end
end
