require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "requires authentication" do
    delete admin_session_path
    get admin_posts_path

    assert_redirected_to new_admin_session_path
  end

  test "renders every read and form action" do
    get admin_posts_path
    assert_response :success
    assert_select "h1", "Публикации"
    assert_select "td", text: "Партнёрский материал", minimum: 1

    get admin_post_path(posts(:published_article))
    assert_response :success

    get new_admin_post_path
    assert_response :success
    assert_select "select[name='post[placement]']"
    assert_select "select[name='post[supplier_id]'] option[value='#{suppliers(:kraft_factory).id}']"
    assert_select "select[name='post[supplier_id]'] option[value='#{suppliers(:inactive_studio).id}']", count: 0
    assert_select "input[name='post[cta_label]']"
    assert_select "input[name='post[external_url]']"

    get edit_admin_post_path(posts(:published_article))
    assert_response :success
  end

  test "creates a partner post with its supplier and permitted call to action" do
    assert_difference -> { Post.count }, 1 do
      post admin_posts_path, params: {
        post: {
          category_id: categories(:suppliers).id,
          supplier_id: suppliers(:kraft_factory).id,
          title: "Партнёрский разбор",
          slug: "partner-editorial",
          summary: "Материал фабрики.",
          body: "Подробный текст партнёрского материала.",
          kind: "article",
          status: "published",
          placement: "partner",
          cta_label: "Открыть компанию",
          external_url: "",
          views_count: 50_000
        }
      }
    end

    post_record = Post.find_by!(slug: "partner-editorial")
    assert_redirected_to admin_post_path(post_record)
    assert post_record.partner?
    assert_equal suppliers(:kraft_factory), post_record.supplier
    assert_equal "Открыть компанию", post_record.cta_label
    refute post_record.has_attribute?(:views_count)
  end

  test "creates an external placement with a safe url" do
    post admin_posts_path, params: {
      post: {
        category_id: categories(:business_cases).id,
        title: "Сервис для небольших брендов",
        slug: "external-business-offer",
        summary: "Описание предложения.",
        body: "Подробности предложения.",
        kind: "article",
        status: "draft",
        placement: "external",
        cta_label: "Узнать условия",
        external_url: "https://offers.example.test/small-business"
      }
    }

    post_record = Post.find_by!(slug: "external-business-offer")
    assert_redirected_to admin_post_path(post_record)
    assert post_record.external?
    assert_equal "https://offers.example.test/small-business", post_record.external_url
  end

  test "renders placement validation errors with status 422" do
    assert_no_difference -> { Post.count } do
      post admin_posts_path, params: {
        post: {
          category_id: categories(:suppliers).id,
          title: "Материал без компании",
          slug: "partner-without-supplier",
          summary: "Ошибка настройки.",
          body: "Такую публикацию нельзя сохранить.",
          kind: "article",
          status: "draft",
          placement: "partner"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "[role='alert']"
    assert_select "select[name='post[placement]'] option[selected][value='partner']"
  end

  test "creates a draft with allowed parameters only" do
    old_time = 20.years.ago

    assert_difference -> { Post.count }, 1 do
      post admin_posts_path, params: {
        post: {
          category_id: categories(:materials).id,
          title: "Новая статья",
          slug: "new-article",
          summary: "Короткое описание.",
          body: "Полный текст статьи.",
          kind: "article",
          status: "draft",
          featured: true,
          cover_asset: "",
          created_at: old_time
        }
      }
    end

    post_record = Post.order(:created_at).last
    assert_redirected_to admin_post_path(post_record)
    assert post_record.draft?
    assert_operator post_record.created_at, :>, 1.minute.ago
  end

  test "renders validation errors with status 422" do
    assert_no_difference -> { Post.count } do
      post admin_posts_path, params: { post: { title: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "[role='alert']"
  end

  test "updates and deletes a post" do
    post_record = posts(:draft_article)

    patch admin_post_path(post_record), params: {
      post: { title: "Опубликованный обзор", status: "published" }
    }
    assert_redirected_to admin_post_path(post_record)
    assert_equal "Опубликованный обзор", post_record.reload.title
    assert post_record.published?

    assert_difference -> { Post.count }, -1 do
      delete admin_post_path(post_record)
    end
    assert_redirected_to admin_posts_path
  end

  private

  def sign_in
    post admin_session_path, params: {
      session: { email: admins(:owner).email, password: "correct-horse-battery" }
    }
  end
end
