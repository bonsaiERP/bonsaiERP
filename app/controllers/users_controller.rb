class UsersController < ApplicationController
  respond_to :html, :xml, :json

  def new
    @user = User.new
    respond_with(@user)
  end

  def create
    @user = User.new(params[:user])
    flash[:notice] if @user.save
    debugger
    respond_with(@user)
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end
end
