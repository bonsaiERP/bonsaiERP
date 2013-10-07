require 'spec_helper'

describe Loans::Receive do
  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100,
      interests: 10
    }
  }

  it "#initialize with code" do
    l = Loans::Receive.new
    y = Date.today.year.to_s[2..4]
    expect(l.name).to eq("PR-#{y}-0001")
  end

end
