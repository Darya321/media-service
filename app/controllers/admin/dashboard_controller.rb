class Admin::DashboardController < Admin::BaseController
  def show
    @counts = {
      posts: Post.count,
      materials: Material.count,
      suppliers: Supplier.count,
      inquiries: Inquiry.count
    }
    @recent_inquiries = Inquiry.order(created_at: :desc).limit(5)
  end
end
