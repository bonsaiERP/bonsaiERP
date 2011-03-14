require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Incomes Feature", %q{
  In order to make an income I must login 
  create an income
  and pay for all
} do

  background do
    create_organisation

    #Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 0) {|a| a.id = 1 }
    #CashRegister.create!(:name => 'Cash register Bs.', :amount => 0, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}

    #Contact.create!(:code => 'C-0001',:name => 'karina', :matchcode => 'karina', :address => 'Mallasa') {|c| c.id = 1 }

    #create_currency_rates

  end

  scenario "Create an income and pay", :js => true do

    #login_as User.find_by_email("boris@example.com")
    visit '/users/sign_out'
    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar' 

    Capybara.javascript_driver = :akephalos
    page.evaluate_script("$('body').html('Hola')")
    puts page.body

    #within('#organisations_list') { click_link('a') }  
    #within('#main_menu') do
    #  page.evaluate_script("$('#main_menu li:eq(1)>ul').show()")
    #  click_link('Ventas')
    #end

    #click_link "Nueva venta"

  end
end
