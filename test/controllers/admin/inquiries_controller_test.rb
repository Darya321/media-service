require "test_helper"

class Admin::InquiriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "requires authentication" do
    delete admin_session_path
    get admin_inquiries_path
    assert_redirected_to new_admin_session_path
  end

  test "renders index and inquiry detail" do
    get admin_inquiries_path
    assert_response :success
    assert_select "h1", "Заявки"

    get admin_inquiry_path(inquiries(:candle_boxes))
    assert_response :success
    assert_includes response.body, inquiries(:candle_boxes).email
  end

  test "updates only status and ignores calculator and price tampering" do
    inquiry = inquiries(:candle_boxes)
    original = inquiry.attributes.slice("quantity", "length_mm", "estimated_unit_price", "estimated_total_price")

    patch admin_inquiry_path(inquiry), params: {
      inquiry: {
        status: "reviewing",
        quantity: 1,
        length_mm: 1,
        estimated_unit_price: 1,
        estimated_total_price: 1
      }
    }

    assert_redirected_to admin_inquiry_path(inquiry)
    inquiry.reload
    assert inquiry.reviewing?
    assert_equal original, inquiry.attributes.slice(*original.keys)
  end

  test "rejects an unknown status" do
    patch admin_inquiry_path(inquiries(:candle_boxes)), params: { inquiry: { status: "invented" } }
    assert_response :unprocessable_entity
  end

  private

  def sign_in
    post admin_session_path, params: { session: { email: admins(:owner).email, password: "correct-horse-battery" } }
  end
end
