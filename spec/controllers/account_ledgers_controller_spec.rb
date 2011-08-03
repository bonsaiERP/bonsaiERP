require 'spec_helper'

describe AccountLedgersController do
  describe "GET /show/1" do
    before(:each) do
      al = AccountLedger.new {|al| al.id = 1}
      AccountLedger.stubs(:org => stub(:find => al))
    end

    it 'when setting should use normal tempate' do
      stub_auth
      get :show, :id => 1, :ac_id => 10
      response.should render_template('account_ledgers/show')
    end

    it 'should render contact template' do
      AccountLedger.any_instance.stubs(:account_accountable_type => 'Contact')
      stub_auth
      get :show, :id => 1, :ac_id => 10
      response.should render_template('account_ledgers/show_contact')
    end
  end
end
