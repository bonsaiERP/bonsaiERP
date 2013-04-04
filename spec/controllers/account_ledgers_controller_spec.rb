require 'spec_helper'

describe AccountLedgersController do
  before(:each) do
    stub_auth
  end

  describe "GET /show/1" do

    it 'Ok' do
      AccountLedger.stub(find: (build :account_ledger, id: 1))

      get :show, id: 1
      response.should render_template('account_ledgers/show')
      assigns(:ledger).should be_is_a(AccountLedgerPresenter)
    end
  end

  describe 'PUT /account_ledgers/:id/conciliate' do
    before(:each) do
      AccountLedger.stub(find: (build :account_ledger, id: 1, conciliation: false))
      UserSession.user = build(:user, id: 10)
    end

    it '#conciliate' do
      ConciliateAccount.any_instance.should_receive(:conciliate!).and_return(true)

      put :conciliate, id: 1, conciliate_commit: 'Conciliate'
  
      response.should redirect_to(account_ledger_path(1))
      flash[:notice].should be_present
    end


    it '#null' do
      AccountLedger.any_instance.should_receive(:save).and_return(true)

      put :conciliate, id: 1, null_commit: 'Null'
  
      response.should redirect_to(account_ledger_path(1))
      flash[:notice].should be_present
      assigns(:ledger).nuller_id.should eq(10)
      assigns(:ledger).nuller_datetime.should be_is_a(Time)
    end
  end
end
