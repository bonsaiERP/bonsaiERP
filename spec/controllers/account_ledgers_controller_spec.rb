require 'spec_helper'

describe AccountLedgersController do
  let(:user) { build :user, id: 10}

  before(:each) do
    stub_auth
    controller.stub(current_tenant: 'public')
    UserSession.user = user
  end

  describe 'GET /' do

    it "Ok" do
      #AccountLedger.should be_respond_to(:pendent)
      #AccountLedger.should_receive(:pendent).and_return([])
      get :index

      expect(response.ok?).to eq(true)
    end
  end

  describe "GET /show/1" do
    it 'Ok' do
      AccountLedger.stub(find: (build :account_ledger, id: 1))

      get :show, id: 1
      response.should render_template(:show)
      expect(assigns(:ledger).class).to eq(AccountLedgerPresenter)
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

      response.should redirect_to(controller.account_ledger_path(1))
      expect(controller.flash[:notice].present?).to eq(true)
    end

    it '#conciliate error' do
      ConciliateAccount.any_instance.should_receive(:conciliate!).and_return(false)

      patch :conciliate, id: 1

      response.should redirect_to(controller.account_ledger_path(1))
      expect(flash[:error].present?).to eq(true)
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

      response.should redirect_to(controller.account_ledger_path(1))
      expect(controller.flash[:notice].present?).to eq(true)
    end

    it '#conciliate error' do
      NullAccountLedger.any_instance.should_receive(:null!).and_return(false)

      patch :null, id: 1

      response.should redirect_to(controller.account_ledger_path(1))
      expect(flash[:error].present?).to eq(true)
    end
  end
end
