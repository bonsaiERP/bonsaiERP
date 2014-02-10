# encoding: utf-8 # author: Boris Barroso
# email: boriscyber@gmail.com
class UsersController < ApplicationController

  # GET /users/:id
  def show
  end

  # GET /users/:id/edit
  def edit
  end

  # PUT /users/:id
  def update
    if current_user.update_attributes(user_params)
      redirect_to current_user, notice: "Se ha actualizado correctamente sus datos."
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :email,
        :first_name, :last_name,
        :address, :phone, :mobile
      )
    end
end
