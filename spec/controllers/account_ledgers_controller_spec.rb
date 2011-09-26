require 'spec_helper'

describe AccountLedgersController do
  describe "GET /show/1" do
    before(:each) do
      al = AccountLedger.new {|al| al.id = 1}
      AccountLedger.stub!(:org => stub(:find => al))
    end

    it 'when setting should use normal tempate' do
      stub_auth
      get :show, :id => 1, :ac_id => 10
      response.should render_template('account_ledgers/show')
    end

    it 'should render contact template' do
      AccountLedger.any_instance.stub!(:to_accountable_type => 'Contact')
      stub_auth
      get :show, :id => 1, :ac_id => 10
      response.should render_template('account_ledgers/show_contact')
    end
  end

  describe "GET /accounts_ledgers/new" do
    it 'should assing correctly' do
      stub_auth
      AccountLedger.stub!(:new_money => AccountLedger.new)

      get :new, :account_id => 1, :operation => "in"
      
      response.should render_template("account_ledgers/new")
    end

    it 'should redirect because it is not a money account' do
      stub_auth
      AccountLedger.stub!(:new_money => false)

      get :new, :account_id => 1, :operation => "in"
      
      response.should redirect_to("/dashboard")
    end
  end

  describe "GET /account_ledgers/new_transference" do
    
  end
end
