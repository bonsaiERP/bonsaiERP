# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module HelperMethods
  # Put helper methods you need to be available in all tests here.
  
  # Create a user
  def create_user(attributes = {})
    attributes.delete(:password)
    attributes.delete(:password_confirmation)
    user = Factory.create(:user, attributes)
    User.confirm_by_token(user.confirmation_token)
    UserSession.current_user = user
    user
  end

  # login
  def login_as(user)
    visit '/users/sign_out'
    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar'
  end

  # Creates a user logins and creates and organisation
  def create_organisation(attributes)
    
  end

  def create_currencies
    YAML.load_file("#{Rails.root}/config/defaults/currencies.yml").each do |c|
      Factory.create :currency, c
    end
  end

  def create_countries
    YAML.load_file("#{Rails.root}/config/defaults/countries.yml").each do |c|
      Factory.create :country, c
    end
  end

  def set_organisation
    create_countries
    create_currencies
    @user = create_user
    login_as @user

    click_link "Nueva empresa"

    select 'Bolivia', :from => 'organisation[country_id]'
    select 'boliviano', :from => 'organisation[currency_id]'
    fill_in 'organisation[name]', :with => 'Prueba'
    fill_in 'organisation[address]', :with => 'Cerror #51'
    fill_in 'organisation[phone]', :with => 'empresa@mail.com'
    click_button 'Crear'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
