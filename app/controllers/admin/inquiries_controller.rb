class Admin::InquiriesController < Admin::BaseController
  before_action :set_inquiry, only: %i[show update]

  def index
    @inquiries = Inquiry.includes(:supplier, :material).order(created_at: :desc)
  end

  def show
  end

  def update
    status = inquiry_params[:status]

    if Inquiry.statuses.key?(status) && @inquiry.update(status: status)
      redirect_to admin_inquiry_path(@inquiry), notice: "Статус заявки обновлён"
    else
      @inquiry.errors.add(:status, "не поддерживается") unless Inquiry.statuses.key?(status)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_inquiry
    @inquiry = Inquiry.includes(:supplier, :material).find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(:status)
  end
end
