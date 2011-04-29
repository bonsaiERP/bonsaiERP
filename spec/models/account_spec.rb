# encoding: utf-8
require 'spec_helper'

describe Account do

  before :each do
    OrganisationSession.set(:id => 1)
    UserSession.current_user = User.new {|u| u.id = 1 }
  end

  it 'should create a Bank account' do
    b = Bank.new(:name => 'Uno', :number => '12121', :amount => 1000,:currency_id => 1 )

    b.save.should == true
    b.account_ledgers.size.should == 1

    b.total_amount.should == 0
    b.total_pendent.should == 1000
  end
end
