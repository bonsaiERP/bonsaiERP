require 'spec_helper'

describe ContactBalanceStatus do
  class TransTest < Struct.new(:tot, :tot_cur, :currency)
  end
  let(:organisation) { build :organisation, currency: 'BOB'}

  before(:each) do
    OrganisationSession.organisation = organisation
  end

  let(:balances) {
    [
      TransTest.new('10.2', '10.0', 'BOB'),
      TransTest.new('70.0', '10.0', 'USD'),
      TransTest.new('45.0', '5.0', 'EUR')
    ]
  }

  it "#calculate" do
    cbal = ContactBalanceStatus.new(balances)

    cbal.create_balances.should eq({
      'TOTAL' => 10.2 + 70 + 45,
      'BOB' => 10.2,
      'USD' => 10.0,
      'EUR' => 5.0
    })
  end

  it "empty array" do
    cbal = ContactBalanceStatus.new([])
    
    cbal.create_balances.should eq({'TOTAL' => 0.0})
  end
end
