# encoding: utf-8
require 'spec_helper'

describe Payment do
  it { should validate_presence_of(:transaction_id) }
  it { should validate_presence_of(:account_id) }

  it { should have_valid(:amount).when(1) }
  it { should_not have_valid(:amount).when(-1) }
  it { should have_valid(:interest).when(1) }
  it { should_not have_valid(:interest).when(-1) }

  let(:valid_attributes) {
    {
      transaction_id: 10, account_id: 2, exchange_rate: 0,
      amount: 50, interest: 0, reference: 'El primer pago'
    }
  }

  let(:transaction_id) { valid_attributes[:transaction_id] }
  let(:account_id) { valid_attributes[:account_id] }

  subject { Payment.new(valid_attributes) }

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

      subject.errors[:base].should_not be_blank
    end
  end

  context "Valid" do
    let(:transaction) { build :transaction, id: transaction_id }
    let(:account) { build :account, id: account_id }

    before(:each) do
      Transaction.stub!(:find).with(transaction_id).and_return(transaction)
      Account.stub!(:find).with(account_id).and_return(account)
    end

    it "Valid when" do
      p = Payment.new(transaction_id: transaction_id, account_id: account_id)
      p.should_not be_valid
    end
  end

end
