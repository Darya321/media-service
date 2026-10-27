class Admin::BaseController < ApplicationController
  layout "admin"

  helper_method :current_admin, :admin_signed_in?
  before_action :require_admin

  private

  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id]) if session[:admin_id]
  end

  def admin_signed_in?
    current_admin.present?
  end

  def require_admin
    return if admin_signed_in?

    redirect_to new_admin_session_path, alert: "Войдите, чтобы открыть панель управления"
  end
end
