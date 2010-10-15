# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Login" do

  background do
    @user = Factory.create(:user)
    User.confirm_by_token(@user.confirmation_token)
    UserSession.current_user = @user
    login_as @user
  end

  scenario "Scenario login" do
    visit '/users/sign_out'
    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar'

    page.should have_css('#flashNotice', :text => 'Ingreso correctamente')
    page.should have_css('h1', :text => 'Empresas')
  end

  scenario "User should not be able to access dashboard if not logged" do
    visit '/users/sign_out'
    visit '/dashboard'
    page.current_path.should == '/users/sign_in'
    #page.response.should be_redirect
  end
end

