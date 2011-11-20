s encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class HomeController < ApplicationController
  layout "home", :only => :index

  def index
    @page = params[:page] || "home"
    params[:page] = @page
  end
 
end

