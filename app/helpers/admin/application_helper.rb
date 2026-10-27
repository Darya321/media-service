module Admin::ApplicationHelper
  def admin_nav_class(path)
    "admin-nav__link#{' admin-nav__link--active' if current_page?(path)}"
  end
end
