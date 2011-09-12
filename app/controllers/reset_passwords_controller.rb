# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ResetPasswordsController < ApplicationController
  def new
    @user = User.new
  end


  def create

  end
end
