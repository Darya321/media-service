require "application_system_test_case"

class AdminEditorialCrudTest < ApplicationSystemTestCase
  test "editor creates a category and draft, publishes it, then removes safe records" do
    visit new_admin_session_path
    fill_in "Email", with: admins(:owner).email
    fill_in "Пароль", with: "correct-horse-battery"
    click_button "Войти"

    click_link "Категории"
    click_link "Добавить категорию"
    fill_in "Название", with: "Практика"
    fill_in "Адрес страницы", with: "practice"
    fill_in "Описание", with: "Рабочие инструкции."
    click_button "Создать категорию"
    assert_text "Практика"

    click_link "Публикации"
    click_link "Добавить публикацию"
    select "Практика", from: "Категория"
    fill_in "Заголовок", with: "Как подготовить тираж"
    fill_in "Адрес страницы", with: "prepare-print-run"
    fill_in "Краткое описание", with: "Пошаговая инструкция."
    fill_in "Текст", with: "Проверьте размеры, материал и макет перед заказом."
    select "Инструкция", from: "Тип"
    select "Черновик", from: "Статус"
    click_button "Создать публикацию"
    assert_text "Как подготовить тираж"
    assert_text "Черновик"

    click_link "Редактировать"
    select "Опубликовано", from: "Статус"
    click_button "Сохранить публикацию"

    post_record = Post.find_by!(title: "Как подготовить тираж")
    visit post_path(post_record)
    assert_text "Как подготовить тираж"

    visit admin_post_path(post_record)
    click_button "Удалить публикацию"
    assert_text "Публикация удалена"

    category = Category.find_by!(name: "Практика")
    visit admin_category_path(category)
    click_button "Удалить категорию"
    assert_text "Категория удалена"
  end
end
