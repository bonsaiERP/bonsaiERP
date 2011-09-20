# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Organisations", "In order to create an organisation I must login" do

  background do
    UserSession.current_user = User.new(:first_name => 'Violeta', :last_name => 'Barroso') {|u| u.id = 1}
    create_countries
    create_currencies
  end

  scenario "Scenario create organisation" do
    o = Organisation.new(:name => 'Violetas', :currency_id => 1, :country_id => 1, 
                         :phone => '7881221', :mobile => '789123434',
                         :address => 'Mallasa calle 4 Nº 222', 
                         :preferences => {"item_discount" => "2", "general_discount" => "0.5" })

    o.save.should == true

    o.reload
    o.taxes.map(&:organisation_id).uniq.should be_empty
    o.units.map(&:organisation_id).uniq.should == [o.id]
    o.account_types.map(&:organisation_id).uniq.should == [o.id]
    o.account_types.map(&:account_number).uniq.include?(nil).should == false

    o.due_date.should == 30.days.from_now.to_date
    o.links.first.user_id.should == 1
    o.links.first.creator.should == true
    o.links.first.abbreviation.should == "GEREN"

    # Preferences
    o.preferences.should == {:item_discount => 2, :general_discount => 0.5 }

  end

  scenario "Create account and then organisation", :driver => :rack_test do
    visit "/"
    click_link "register"
    
    fill_in "Email", :with => 'admin@example.com'
    fill_in "Contraseña", :with => 'demo123'
    click_button('Registrate')

    ActionMailer::Base.deliveries.size.should == 1
    u = User.find_by_email("admin@example.com")
    u.confirm_token(u.confirmation_token)

    # Log in
    visit "/users/sign_in"
    fill_in "Email", :with => 'admin@example.com'
    fill_in "Contraseña", :with => 'demo123'
    click_button('Ingresar')

    page.current_path.should == new_organisation_path

    # Create organisation
    fill_in 'Nombre de su empresa', :with => 'bonsailabs'
    select 'Dolar', :from => 'Moneda base'
    select 'Bolivia', :from => 'País'
    fill_in 'Teléfono', :with => '2790123'
    fill_in 'Dirección', :with => 'Los Pinos B 80, dpto. 201'

    click_button 'Salvar'

    page.current_path.should == '/dashboard'

    org = Organisation.last
    org.accounts.map(&:organisation_id).uniq.should == [ org.id ]
    org.accounts.select {|a| a.original_type == "Income" }.size.should == 1
    org.accounts.select {|a| a.original_type == "Buy" }.size.should == 1
    org.accounts.select {|a| a.original_type == "Expense" }.size.should == 1
    org.accounts.select {|a| a.original_type == "Failed" }.size.should == 1
    org.accounts.select {|a| a.original_type == "Unpayable" }.size.should == 1
    org.accounts.select {|a| a.original_type == "Interest" }.size.should == 1
  end


  scenario "Create Organisation and fail creating accounts", :driver => :rack_test do

    u = User.create(:email => 'fail@example.com', :password => 'demo123', :password_confirmation => 'demo123')
    u.confirm_token(u.confirmation_token)

    # Log in
    visit "/users/sign_in"
    fill_in "Email", :with => 'fail@example.com'
    fill_in "Contraseña", :with => 'demo123'
    click_button('Ingresar')

    page.current_path.should == new_organisation_path

    Organisation.any_instance.stubs(:create_base_accounts => false)

    # Create organisation
    fill_in 'Nombre de su empresa', :with => 'bonsailabs'
    select 'Dolar', :from => 'Moneda base'
    select 'Bolivia', :from => 'País'
    fill_in 'Teléfono', :with => '2790123'
    fill_in 'Dirección', :with => 'Los Pinos B 80, dpto. 201'

    click_button 'Salvar'

    page.current_path.should == '/users/sign_in'
    page.has_css?("#flashError")

  end
end
