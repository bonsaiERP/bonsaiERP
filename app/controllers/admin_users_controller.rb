class AdminUsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    admin_user = AdminUser.new(User.new(user_params))

    if admin_user.add_user
      redirect_to configurations_path,  notice: "El usuario ha sido adicionado."
    else
      @user = admin_user.user
      render 'new'
    end
  end

  def edit
  end

  def update
  end

private
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone,:mobile, :address, :rol)
  end
end
