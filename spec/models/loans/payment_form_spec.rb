require 'spec_helper'

describe Loans::PaymentForm do
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:reference) }

  it "valid loan" do
    l = Loans::PaymentForm.new
    l.should be_invalid

    l.errors[:account_to].should_not be_blank
    l.errors[:loan].should_not be_blank
  end

  it "valid loan Amount" do
    lp = Loans::PaymentForm.new(amount: 1000)

    lp.stub(loan: Loan.new(total: 500, amount: 500))

    lp.valid?
    lp.errors[:amount].should eq([I18n.t('errors.messages.less_than_or_equal_to', count: 500.0)])
  end
end