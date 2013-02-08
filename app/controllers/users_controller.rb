# encoding: utf-8 # author: Boris Barroso
# email: boriscyber@gmail.com
class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :check_if_default_password, :only => [:password, :update_password]

  def show
    @user = User.find(params[:id])
    redirect_to "/422" unless @user

    respond_with(@user)
  end

  # GET /users/:id/edit
  def edit
    PgTools.reset_search_path
    @user = User.find_by_id(current_user.id)
  end

  # PUT /users/:id/update_user
  def update
    PgTools.reset_search_path
    @user = User.find_by_id(current_user.id)
    h = params[:user]
    h.delete(:password)

    if @user.update_attributes(h)
      redirect_to current_user, :notice => "Se ha actualizado correctamente sus datos."
    else
      render :action => 'edit'
    end
  end
end
