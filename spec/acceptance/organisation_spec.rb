require File.dirname(__FILE__) + '/acceptance_helper'

feature "Organisation", "In order to create an organisation I must login" do

  background do
    user = Factory.build(:user)
    User.confirm_by_token(user.confirmation_token)
    UserSession.current_user = user
  end

  scenario "Scenario create organisation" do
    visit '/'

    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'

    click_button 'Ingresar'

    click_link 'Nueva empresa'

    page.should have_css('form')
    fill_in 'organisation[]', :with => ''
    #page.should have_css('#flashNotice')
  end
end
