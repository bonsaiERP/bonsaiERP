# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'spec_helper'

describe Contact do
  before(:each) do
    @params = { 
      :first_name => 'Boris', :last_name => "Barroso", :organisation_name => 'bonsailabs',
      :email => 'boris@bonsailabs.com', :matchcode => 'Boris Barroso',
      :address => "Los Pinos Bloque 80\nDpto. 202", :phone => '2745620', 
      :mobile => '70681101', :tax_number => '3376951' }

    OrganisationSession.set = { name: "ecuanime", id: 1, curency_id: 1 }
    #Organisation.stubs(:find).returns( stub(@@stub_model_methods.merge({:id => 1})) )

    AccountType.stub!(find_by_account_number: stub(id: 1))
  end

  #it { should validates_presence_of :ctype }

  it 'should create a valid' do
    Client.create!(@params)
  end

  it 'should create a new account when defined for a a currency' do
    c = Client.create!(@params)
    c.accounts.count.should  eq(1)

    Currency.create!( symbol: "$us", name:"dolar") {|cur| cur.id = 2}

    ac = c.get_contact_account(2)
    ac.class.should == Account
    ac.should be_persisted
    ac.currency_id.should == 2
    ac.amount.should == 0

    c.accounts(true).count.should eq(2)
  end

end


