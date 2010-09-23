require File.dirname(__FILE__) + '/acceptance_helper'

feature "Login" do

  background do
    user = Factory.build(:user)
    User.confirm_by_token(user.confirmation_token)
    UserSession.current_user = user
  end

  scenario "Scenario login" do
    visit '/'
    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar'

    #User.first.first_name.should == 'Boris'
    page.should have_css('#flashNotice', :text => 'Ingreso correctamente')
  end
end
