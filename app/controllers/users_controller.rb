# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class UsersController < ApplicationController
  respond_to :html, :xml, :json

  def new
    @user = User.new
    respond_with(@user)
  end

  def create
    @user = User.new(params[:user])
    flash[:error] = t("flash.error") unless @user.save
    respond_with(@user)
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end
end
