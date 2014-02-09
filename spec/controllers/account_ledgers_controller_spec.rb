require 'spec_helper'

describe AccountLedgersController do
  before(:each) do
    stub_auth
  end

  describe 'GET /' do

    it "Ok" do
      AccountLedger.should be_respond_to(:pendent)
      AccountLedger.should_receive(:pendent).and_return([])
      get :index

      response.should be_ok
    end
  end

  describe "GET /show/1" do
    it 'Ok' do
      AccountLedger.stub(find: (build :account_ledger, id: 1))

      get :show, id: 1
      response.should render_template('account_ledgers/show')
      assigns(:ledger).should be_is_a(AccountLedgerPresenter)
    end
  end

  describe 'PATCH /account_ledgers/:id/conciliate' do
    before(:each) do
      AccountLedger.stub(find: (build :account_ledger, id: 1))
      UserSession.user = build(:user, id: 10)
    end

    it '#conciliate' do
      ConciliateAccount.any_instance.should_receive(:conciliate!).and_return(true)

      patch :conciliate, id: 1

      response.should redirect_to(account_ledger_path(1))
      flash[:notice].should be_present
    end

    it '#conciliate error' do
      ConciliateAccount.any_instance.should_receive(:conciliate!).and_return(false)

      patch :conciliate, id: 1

      response.should redirect_to(account_ledger_path(1))
      flash[:error].should be_present
    end
  end

  describe 'PATCH /account_ledgers/:id/null' do
    before(:each) do
      AccountLedger.stub(find: (build :account_ledger, id: 1))
      UserSession.user = build(:user, id: 10)
    end

    it '#conciliate' do
      NullAccountLedger.any_instance.should_receive(:null!).and_return(true)

      patch :null, id: 1

      response.should redirect_to(account_ledger_path(1))
      flash[:notice].should be_present
    end

    it '#conciliate error' do
      NullAccountLedger.any_instance.should_receive(:null!).and_return(false)

      patch :null, id: 1

      response.should redirect_to(account_ledger_path(1))
      flash[:error].should be_present
    end
  end
end
