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
    fill_in 'user[email]', :with => user.email
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar'
  end
  
  # Creates a user logins and creates and organisation
  def create_organisation(attributes = {})
    if attributes.empty?
      y = YAML.load_file("#{Rails.root}/config/defaults/organisations.yml")
      attributes = y.first
    end
    @user = create_user
    create_countries
    create_currencies
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    org = Organisation.create!(attributes)
    #org.currency_ids = [1]
  end

  # Create organisaton and items
  def create_organisation_items
    create_organisation
  end

  def create_currencies
    YAML.load_file("#{Rails.root}/config/defaults/currencies.yml").each do |c|
      Currency.create!( c ) {|cur| cur.id = c["id"] }
    end
  end

  def create_currency_rates
    CurrencyRate.create!(:currency_id => 2, :rate => 7) {|cr| cr.active = true }
    CurrencyRate.create!(:currency_id => 3, :rate => 9.4) {|cr| cr.active = true }
  end

  def create_countries
    YAML.load_file("#{Rails.root}/config/defaults/countries.yml").each do |c|
      Factory.create :country, c
    end
  end

  def create_contacts
    YAML.load_file("#{Rails.root}/config/defaults/contacts.yml").each do |c|
      Factory.create :contact, c
    end
  end

  def create_items
    YAML.load_file("#{Rails.root}/config/defaults/items.yml").each do |i|
      Factory.create :item, i
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

  def set_exchange_rate

  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
