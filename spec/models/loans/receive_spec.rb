require 'spec_helper'

describe Loans::Receive do
  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100,
      account_to_id: 10
    }
  }

  it { should have_many(:ledger_ins) }
  it { should have_many(:payments) }
  it { should have_many(:interest_ledgers) }

  it "#initialize with code" do
    l = Loans::Receive.new {}
    y = Date.today.year.to_s[2..4]
    expect(l.name).to eq("PR-#{y}-0001")
  end

end
