require 'spec_helper'

describe Loans::ReceiveForm do
  let(:attributes) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1
    }
  end

  it "#create" do
    lf = Loans::ReceiveForm.new(attributes)

    # loan
    lf.loan.should be_is_a(Loans::Receive)
    lf.loan.amount.should == attributes.fetch(:total)
    lf.loan.date.should eq(attributes.fetch(:date))
    lf.loan.due_date.should eq(attributes.fetch(:due_date))
    # ledger
    lf.ledger.amount.should == 100
    expect(lf.ledger.operation).to eq('lrcre')
  end
end
