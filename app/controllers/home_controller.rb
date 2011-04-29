# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class HomeController < ApplicationController
  def index
    if !current_user
      redirect_to "/users/sign_in"
    elsif current_user.organisations.any?
      set_organisation_session(current_user.organisations.first)
      session[:user] = {:rol => current_user.link.rol }

      redirect_to "/dashboard"
    elsif current_user.organisations.empty?
      redirect_to "/organisations/new"
    end
  end
end

