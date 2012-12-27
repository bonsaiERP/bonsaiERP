# encoding: utf-8
require 'spec_helper'

describe Payment do
  it { should_not have_valid(:amount).when(-1) }
  it { should have_valid(:interest).when(1) }
  it { should_not have_valid(:interest).when(-1) }

  let(:valid_attributes) {
    {
      transaction_id: 10, account_id: 2, exchange_rate: 1,
      amount: 50, interest: 0, reference: 'El primer pago',
      verification: false
    }
  }

  let(:transaction_id) { valid_attributes[:transaction_id] }
  let(:account_id) { valid_attributes[:account_id] }

  subject { Payment.new(valid_attributes) }

  it "initializes verification false" do
    p = Payment.new
    p.verification.should be_false
  end

  context "Invalid" do
    subject { Payment.new }

    it "checks valid presence" do
      subject.should_not be_valid

      [:transaction, :transaction_id, :account, :account_id, :amount,
      :exchange_rate, :interest].each do |met|
        subject.errors[met].should_not be_blank
      end
    end

    it "valid_amount_or_interest" do
      subject.attributes = valid_attributes
      subject.amount = 0
      subject.interest = 0

      subject.should_not be_valid

      subject.errors[:base].should eq([I18n.t('errors.messages.payment.invalid_amount_or_interest')])
    end
  end

  context "Valid and invalid" do
    let(:transaction) { build :transaction, id: transaction_id, balance: 100 }
    let(:account) { build :account, id: account_id }

    before(:each) do
      Transaction.stub!(:find).with(transaction_id).and_return(transaction)
      Account.stub!(:find).with(account_id).and_return(account)
    end

    it "Valid when" do
      p = Payment.new(valid_attributes)
      p.should be_valid
    end

    it "is not valid if amount is greater than transaction_balance" do
      p = Payment.new(valid_attributes.merge(amount: 200) )
      p.should_not be_valid
      p.errors_on(:amount).should eq([I18n.t('errors.messages.payment.greater_amount_than_balance')])
    end
  end

end
