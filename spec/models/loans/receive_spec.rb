require 'spec_helper'

describe Loans::Receive do
  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100
    }
  }

  it { should have_one(:ledger_in) }

  it "#initialize with code" do
    l = Loans::Receive.new {}
    y = Date.today.year.to_s[2..4]
    expect(l.name).to eq("PR-#{y}-0001")
  end

  context 'AccountLedger' do
    before(:each) do
      UserSession.user = build :user, id: 1
    end
    it "#create" do
      l = Loans::Receive.new(attributes)

      l.create.should be_true

      expect(l.ledger).to be_is_a(AccountLedger)
      l.ledger.amount.should == 100
      puts l.ledger.attributes
      l.ledger.should be_is_lrcre
    end
  end

end
