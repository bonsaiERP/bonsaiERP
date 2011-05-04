require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

# Helper method to test all paths
def list_all_paths
  hash = {}
  Rails.application.routes.routes.map do |r|
    hash[r.defaults[:controller]] = [] unless hash[r.defaults[:controller]]
    hash[r.defaults[:controller]] << r.defaults[:action]
  end
  hash
end

feature "Authorization Feature", %q{
  In order to control the logins of users
  I want to be able to control the roles of users
} do

  # Create users and check if users can reach
  background do
    @cont = ApplicationController.new
    #create_countries
    #create_currencies

    ## Create first user
    #@u1 = User.create(:email => 'admin@example.com', :password => 'demo123', :password_confirmation => 'demo123') {|o| o.id = 1}
    #User.confirm_by_token(@u1.confirmation_token)

    #UserSession.current_user = @u1
    #
    #org = Organisation.new(:name => 'bonsailabs', :address => 'Los Pinos', :phone => '2790123', :country_id => 1, :currency_id => 1)
    ## create other users
    #org.account_info = Bank.new(:name => 'Uno', :number => '777-7777', :amount => 100000, :currency_id => 1)
    #org.save
  end

  scenario "check admin authorization" do
    list_all_paths.each do |k, v|
      v.each do |act|
        @cont.send(:check_user_by_rol, 'admin', k, act).should == true
      end
    end
  end

  scenario "check gerency authorization" do
    @cont.send(:check_user_by_rol, 'gerency', 'banks', 'new').should == true
    @cont.send(:check_user_by_rol, 'gerency', 'users', 'add_user').should == false
    @cont.send(:check_user_by_rol, 'gerency', 'users', 'create_user').should == false
  end

  scenario "check inventory authorization" do
    h = { 
      'users' => {'add_user'=> false, 'create_user' => false},
      'banks' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'cash_registers' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'account_ledgers' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false,
                          'new_transference' => false, 'transference' => false, 'conciliate' => false},
      'incomes' => {'approve' => false}
    }

    h.each do |cont, v|
      v.keys.each do |act|
        @cont.send(:check_user_by_rol, 'inventory', cont, act).should == false
      end
    end
  end

  scenario "check sales authorization" do
    h = {
      'users' => {'add_user'=> false, 'create_user' => false},
      'banks' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'cash_registers' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'account_ledgers' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false,
                          'new_transference' => false, 'transference' => false, 'conciliate' => false},
      'incomes' => {'approve' => false},
      'stores' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'inventory_operations' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 
                  'select_store' => false}
    }

    h.each do |cont, v|
      v.keys.each do |act|
        @cont.send(:check_user_by_rol, 'sales', cont, act).should == false
      end
    end
  end
end
