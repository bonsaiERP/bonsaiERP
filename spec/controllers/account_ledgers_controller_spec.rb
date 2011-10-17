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
      al = mock_model(AccountLedger, :ac_id= => true, to_accountable_type: "Contact")
      AccountLedger.stub!(org: stub( find: al))
      stub_auth
      get :show, :id => 1, :ac_id => 10
      response.should render_template('account_ledgers/show')
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

  describe "GET /account_ledgers/new_transference" do
    before(:each) do
      stub_auth
    end

    it 'it should get the correct account' do
      ac = mock_model(Account, id: 1, currency_id: 1)
      Account.stub!(org: stub(find_by_id: ac))

      al = mock_model(AccountLedger)
      AccountLedger.stub!(new_money: al)

      get :new_transference, account_id: 1

      response.should render_template("/new_transference")

      assigns(:account).class.should == Account

      assigns(:account_ledger).class.should == AccountLedger
    end

    it 'should redirect to 422 for errors in account' do
      Account.stub!(org: stub(find_by_id: nil))

      al = mock_model(AccountLedger)
      AccountLedger.stub!(new_money: al)

      get :new_transference, account_id: 1

      response.should redirect_to("/422")
    end

    it 'should redirect if errors on account_ledger' do
      ac = mock_model(Account, id: 1, currency_id: 1)
      Account.stub!(org: stub(find_by_id: ac))

      al = mock_model(AccountLedger)
      AccountLedger.stub!(new_money: false)

      get :new_transference, account_id: 1

      response.should redirect_to("/422")
    end
  end

  describe "POST /account_ledgers/transferences" do
    before(:each) do
      stub_auth
    end

    it 'should save correctly' do
      ac = mock_model(Account, id: 1, currency_id: 1)
      Account.stub!(org: stub(find_by_id: ac))

      al = mock_model(AccountLedger, save: true, id: 1, :reference= => "", account_id: 1)
      AccountLedger.stub!(new_money: al)

      post :transference, account_ledger: {operation: "in", account_id: 1}

      response.should redirect_to "/account_ledgers/1?ac_id=1"
      controller.params[:account_ledger][:operation].should == "trans"
    end

    it 'should redirect if incorrect account' do
      Account.stub!(find_by_id: nil)
      post :transference, account_ledger: {operation: "in", account_id: 2}
      response.should redirect_to("/422")
    end
  end
end
