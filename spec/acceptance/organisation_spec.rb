# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Organisation", "In order to create an organisation I must login" do

  background do
    create_countries
    create_currencies
    @user = create_user
    login_as @user
  end

  scenario "Scenario create organisation" do

    click_link "Nueva empresa"

    select 'Bolivia', :from => 'organisation[country_id]'
    select 'boliviano', :from => 'organisation[currency_id]'
    fill_in 'organisation[name]', :with => 'Prueba'
    fill_in 'organisation[address]', :with => 'Cerror #51'
    fill_in 'organisation[phone]', :with => 'empresa@mail.com'
    click_button 'Crear empresa'

    page.should have_css('#flashNotice', :text => 'Se ha creado la empresa')
    # Verify Organisation Params
    org = Organisation.find_by_name('Prueba')
    org.links.size.should == 1
    org.users.size.should == 1
    org.taxes.size.should > 0

    click_link 'Prueba'

    page.should have_css('#header>h1', :text => 'Prueba')
    page.should have_css('h1', :text => 'Bienvenido')

  end
end
