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
    user.confirm!
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
    #if attributes.empty?
    #  y = YAML.load_file("#{Rails.root}/db/defaults/organisations.yml")
    #  attributes = y.first
    #end
    #@user = create_user
    attributes = {:name => 'Violetas', :currency_id => 1, :country_id => 1, 
                         :phone => '7881221', :mobile => '789123434',
                         :address => 'Mallasa calle 4 Nº 222', 
                         :preferences => {"item_discount" => "2", "general_discount" => "0.5" }}.merge(attributes)

    create_countries
    create_currencies

    if attributes[:id]
      org = Organisation.create!(attributes) {|o| o.id = attributes[:id]}
    else
      org = Organisation.create!(attributes)
    end
    raise "Error creating organisation base accounts" unless org.create_base_accounts
    org
  end

  # Create organisaton and items
  def create_organisation_items
    create_organisation
  end

  def create_items
    YAML.load_file("#{Rails.root}/spec/factories/items.yml").each do |it|
      Item.create!(it) {|item| item.id = it["id"] }
    end
  end

  def create_currencies
    YAML.load_file("#{Rails.root}/db/defaults/currencies.yml").each do |c|
      Currency.create!( c ) {|cur| cur.id = c["id"] }
    end
  end

  def create_currency_rates
    CurrencyRate.create!(:currency_id => 2, :rate => 7) {|cr| cr.active = true }
    CurrencyRate.create!(:currency_id => 3, :rate => 9.4) {|cr| cr.active = true }
  end

  def create_countries
    YAML.load_file("#{Rails.root}/db/defaults/countries.yml").each do |data|
      OrgCountry.create!(data) {|c| c.id = data['id']}
    end
  end

  def create_contacts
    YAML.load_file("#{Rails.root}/db/defaults/contacts.yml").each do |c|
      Factory.create :contact, c
    end
  end

  def create_clients
    YAML.load_file("#{Rails.root}/spec/factories/contacts.yml").each do |c|
      matchcode = "#{c[:first_name]} #{c[:last_name]}"
      Client.create!(c.merge(:matchcode => matchcode) )
    end
  end

  #def create_items
  #  YAML.load_file("#{Rails.root}/db/defaults/items.yml").each do |i|
  #    Factory.create :item, i
  #  end
  #end

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

  def create_account_types
    path = File.join(Rails.root, "db/defaults/account_types.es.yml")
    YAML.load_file(path).each do |v|
      AccountType.create!(v)
    end
  end

  def create_bank(options = {})
    options = {:currency_id => 1, :name => "Bank", :number => "0001"}.merge(options)
    b = Bank.create!(options)
  end

  def contact_parameters(options = {})
    if options[:matchcode].present?
      vals = options[:matchcode].split(" ")
      options[:first_name] = vals[0]
      options[:last_name] = vals[1]
    end

    {:first_name => "First", :last_name => "Last", :address => 'My address'}.merge(options)
  end

  def create_client(options)
    Client.create!(contact_parameters.merge(options))
  end

  def create_supplier(options)
    Supplier.create!(contact_parameters.merge(options))
  end

  def create_staff(options)
    Staff.create!(contact_parameters.merge(options))
  end

  def set_exchange_rate

  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
