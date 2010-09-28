# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Price", "I must be able to create and list prices for a product" do
  background do
    set_organisation
  end

  scenario "Crear crear precio" do
    visit "/prices"
    page.should have_css('a.new', :text => 'Nuevo precio')
  end

end
