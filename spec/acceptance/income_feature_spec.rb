# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Income" do
  background do
    create_organisation_session
    user = User.new_user('demo@example.com', 'demo123')
    user.save!

    user.confirm_token(user.confirmation_token)

    UserSession.current_user = user
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }

  scenario "Create an income", :dirver => :selenium do

    visit "/users/sign_in"

    fill_in "Email", :with => 'demo@example.com'
    fill_in "Contraseña", :with => 'demo123'
    click_button("Ingresar")

    page.current_path.should == '/dashboard'

    visit "/incomes"
    click_link "Nueva venta"

    #selector = '.ui-menu-item a:contains(\"Jack Russell Software\")'
    #fill_in 'Name', :with => 'Jack'
    #sleep(3)
    #page.execute_script " $('#{selector}'). trigger(\"mouseenter\").click();"
    click_link "Nuevo cliente"
    sleep(3)
    fill_in "client_matchcode", :with => 'Juan perez'
    click_button "Salvar"
    sleep(3)
  end

end
