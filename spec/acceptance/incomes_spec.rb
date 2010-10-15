# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Income", "In order to make sales and recive incomes" do
  background do
    create_organisation
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
    page.current_path.should == "/dashboard"
  end
end
