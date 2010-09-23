module HelperMethods
  # Put helper methods you need to be available in all tests here.
  
  def create_user(email = nil, password = nil)
    user = Factory.build(:user)
    User.confirm_by_token(user.confirmation_token)
    UserSession.current_user = user
  end

  def login_with(user)
    visit '/'
    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
