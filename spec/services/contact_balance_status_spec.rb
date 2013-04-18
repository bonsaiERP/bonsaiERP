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

  it "delete 0" do
    arr = [
      TransTest.new('0.0', '0.0', 'BOB'),
      TransTest.new('70.0023', '10.0', 'USD')
    ]
    
    cbal = ContactBalanceStatus.new(arr)

    cbal.create_balances.should eq({
      'TOTAL' => 70,
      'USD' => 10.0
    })
  end

  it "rounds" do
    arr = [
      TransTest.new('10.2', '10.0', 'BOB'),
      TransTest.new('70.0023', '10.0', 'USD')
    ]

    cbal = ContactBalanceStatus.new(arr)

    cbal.create_balances.should eq({
      'TOTAL' => 80.2,
      'BOB' => 10.2,
      'USD' => 10.0
    })
  end

  describe 'Object balance' do
    class ObjBalTest < OpenStruct; end
  
    it "#object_balance" do
      obal = ObjBalTest.new(amount: 10.3.to_d, currency: 'BOB', exchange_rate: 1)

      cbal = ContactBalanceStatus.new(balances)

      res = cbal.object_balance(obal)
      cbal.object_balance(obal).should eq({
        'TOTAL' => 10.2 + 70 + 45 + 10.3,
        'BOB' => 10.2 + 10.3,
        'USD' => 10.0,
        'EUR' => 5.0
      })
    end

    it "#object_balance other currency" do
      obal = ObjBalTest.new(amount: 10.3.to_d, currency: 'USD', exchange_rate: 6.85)

      cbal = ContactBalanceStatus.new(balances)

      res = cbal.object_balance(obal)
      cbal.object_balance(obal).should eq({
        'TOTAL' => (10.2 + 70 + 45 + 10.3 * 6.85 ).round(2),
        'BOB' => 10.2,
        'USD' => 10.0 + 10.3,
        'EUR' => 5.0
      })
    end
  end
end
