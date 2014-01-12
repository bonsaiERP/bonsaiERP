require 'spec_helper'

describe Loans::Give do
  it { should have_one(:ledger_in) }
  it { should have_many(:payments_devolutions) }
  it { should have_many(:interest_ledgers) }

  it "#initialize with code" do
    l = Loans::Give.new {}
    y = Date.today.year.to_s[2..4]
    expect(l.name).to eq("PG-#{y}-0001")
  end
end
