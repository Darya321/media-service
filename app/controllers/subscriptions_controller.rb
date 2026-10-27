class SubscriptionsController < ApplicationController
  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      respond_to do |format|
        format.html { redirect_to root_path(anchor: "subscription"), notice: "Подписка сохранена" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "subscription-form",
            partial: "subscriptions/form",
            locals: { subscription: Subscription.new, message: "Подписка сохранена" }
          )
        end
      end
    else
      message = subscription_error_message
      respond_to do |format|
        format.html { redirect_to root_path(anchor: "subscription"), alert: message }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "subscription-form",
            partial: "subscriptions/form",
            locals: { subscription: @subscription, message: message }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email)
  end

  def subscription_error_message
    if @subscription.errors.details.fetch(:email, []).any? { |error| error[:error] == :taken }
      "Этот email уже подписан"
    else
      "Введите корректный email"
    end
  end
end
