require 'spec_helper'

describe AccountLedger do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
    @params = {:account_id => 1, :amount => 10}
  end

  it 'should make the sum equal to 0' do
    
  end
end
