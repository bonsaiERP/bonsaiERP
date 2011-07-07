require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

def income_params
    d = Date.today
    @income_params = {"active"=>nil, "bill_number"=>"56498797", "account_id"=>1, 
      "exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount" => 3, "project_id"=>1 
    }
    details = [
      { "description"=>"jejeje", "item_id"=>1, "organisation_id"=>1, "price"=>3, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>5, "quantity"=> 20}
    ]
    @income_params[:transaction_details_attributes] = details
    @income_params
end

def pay_plan_params(options)
  d = options[:payment_date] || Date.today
  {:alert_date => (d - 5.days), :payment_date => d,
   :interests_penalties => 0,
   :ctype => 'Income', :description => 'Prueba de vida!', 
   :email => true }.merge(options)
end

feature "Incomes Feature", %q{
  In order to make an income I must login 
  create an income
  and pay for all
} do

  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1, :preferences => {:item_discount => 0, :general_discount => 0})
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    create_organisation
    create_items
    create_user
    create_clients

    @b1 = create_bank(:number => '123', :amount => 0)
    @ac1_id = @b1.account.id
    #CashRegister.create!(:name => 'Cash register Bs.', :amount => 0, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}
    #CashRegister.create!(:name => 'Cash register $.', :amount => 0, :currency_id => 2, :address => 'None') {|cr| cr.id = 3}

    @c1 = create_client(:matchcode => 'Karina Luna')
    @cli1_id = @c1.account.id

  end

  scenario "Create an income", :driver => :selenium do

    #login_as User.find_by_email("boris@example.com")
    visit '/users/sign_out'
    fill_in 'user[email]', :with => 'boris@example.com'
    fill_in 'user[password]', :with => 'demo123'
    click_button 'Ingresar'
    
    visit '/incomes'
    
    sleep 2
    fill_in "contact_autocomplete", :with => "Karina"
    sleep 3

    page.execute_script("$('.ui-menu-item a:contains(Karina)')" )
    sleep 4


  end
end
