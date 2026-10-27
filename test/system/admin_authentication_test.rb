require "application_system_test_case"

class AdminAuthenticationTest < ApplicationSystemTestCase
  test "admin signs in, sees the dashboard, and cannot return after logout" do
    visit admin_root_path

    assert_current_path new_admin_session_path
    fill_in "Email", with: " OWNER@EXAMPLE.TEST "
    fill_in "Пароль", with: "correct-horse-battery"
    click_button "Войти"

    assert_current_path admin_root_path
    assert_text "Панель управления"
    assert_text "Заявки"

    click_button "Выйти"
    assert_current_path new_admin_session_path

    visit admin_root_path
    assert_current_path new_admin_session_path
  end
end
