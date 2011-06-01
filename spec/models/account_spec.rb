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
end
