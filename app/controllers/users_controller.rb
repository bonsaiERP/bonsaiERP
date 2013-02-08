# encoding: utf-8 # author: Boris Barroso
# email: boriscyber@gmail.com
class UsersController < ApplicationController
  before_filter :check_if_default_password, :only => [:password, :update_password]

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

  end
end
