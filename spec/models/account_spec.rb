# encoding: utf-8
require 'spec_helper'

describe Account do

  before :each do
    OrganisationSession.set(:id => 1)
    UserSession.current_user = User.new {|u| u.id = 1 }

    AccountType.create(:name => 'capital') {|a| a.id = 1}
    AccountType.create(:name => 'products/services') {|a| a.id = 2}
  end

  it 'should create an Account' do
    a = Account.create(:name => 'Store 1')
  end

  it 'should make multiple accounts' do
    @stub = Object.new
    arr = (1..3).map {|v| Account.new(name: "ac#{v}") {|val| val.id = v } }

    @stub.stubs(:money => arr)
    Account.stubs(:org => @stub)

    Account.org.money.should == arr

    Account.to_hash(:id, :name).should == {1 => {id:1, name: 'ac1'}, 2 => {id:2, name: 'ac2'}, 3 => {id: 3, name: 'ac3'} }
  end
end
