class Admin::SessionsController < Admin::BaseController
  skip_before_action :require_admin, only: %i[new create]

  def new
    redirect_to admin_root_path if admin_signed_in?
  end

  def create
    admin = Admin.find_by(email: login_params[:email].to_s.strip.downcase)

    if admin&.authenticate(login_params[:password])
      reset_session
      session[:admin_id] = admin.id
      redirect_to admin_root_path, notice: "Вы вошли в панель управления"
    else
      flash.now[:alert] = "Не удалось войти. Проверьте email и пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to new_admin_session_path, notice: "Вы вышли из панели управления"
  end

  private

  def login_params
    params.require(:session).permit(:email, :password)
  end
end
