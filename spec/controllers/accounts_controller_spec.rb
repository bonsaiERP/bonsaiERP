require 'spec_helper'

describe AccountsController do
  before(:each) do
    stub_auth
  end

  describe "GET /accounts/:id" do
    before do
      Account.stub!(:org => stub(:find => Account.new {|a| a.id = 1}))
    end

    it 'should select the correct account view' do
      Account.stub!(:org => stub(:find => Account.new))

      views = ["contact", "bank", "cash"]
      [Client.new, Bank.new, Cash.new].each_with_index do |elem, i|
        Account.any_instance.stub!(:accountable => elem)
        get 'show', :id => 1

        response.should render_template("/accounts/#{views[i]}")
      end
    end

    it 'should assing the correct partial' do
      Account.stub!(:org => stub(:find => Account.new))

      ["incomes", "buys", "expenses"].each do |tab|
        Account.any_instance.stub!(:accountable => Client.new, tab.to_sym => [])
        get 'show', :id => 1, :tab => tab

        assigns(:partial).should == tab
      end
    end

    it 'should assing a correct tab' do
      Account.stub!(:org => stub(:find => Account.new))
      Account.any_instance.stub!(:accountable => Client.new, :incomes => [])


      get 'show', :id => 1, :tab => 'incomes'

      assigns(:partial).should == "incomes"
      assigns(:locals).should be_is_a(Hash)
      assigns(:locals).keys.should include("incomes")
    end

    it 'should assing a correct tab' do
      Account.stub!(:org => stub(:find => Account.new))
      Account.any_instance.stub!(:accountable => Client.new)

      get 'show', :id => 1, :tab => 'transactions'

      assigns(:partial).should == "account_ledgers/money"
      assigns(:locals).should be_is_a(Hash)
      assigns(:locals).keys.should include("ledgers")
      assigns(:locals).keys.should_not include("incomes")
    end

  end

end
