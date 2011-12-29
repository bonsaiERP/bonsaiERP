# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class HomeController < ApplicationController
  layout "home"

  def index
    @page = params[:page] || "home"
    params[:page] = @page
  end
 
  def tour
  end

  def prices
  end

  def team
  end

  def contact
  end
end

