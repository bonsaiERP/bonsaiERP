# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Income", "In order to make sales and recive incomes" do
  background do
    create_organisation
    create_contacts
    create_items
    @user = User.first
  end

  #scenario "Test create_organisation" do
  #  create_organisation
  #  org = Organisation.first
  #  org.id.should == 1
  #  org.name == 'ecuanime'
  #end

  scenario "Make a sale to receive income" do
    login_as(@user)
    page.current_path.should == "/"
    click_link "ecuanime"
    Item.all.size.should > 1
    click_link "Ingresos"
    page.current_path.should == "/incomes"
    #click_link "Nuevo"
    #visit '/transactions'
    puts "Antes de post"
    post :create, :par => {:prueba => 'VALOR'}
    puts page.body
    puts "Fin"
  end
end
