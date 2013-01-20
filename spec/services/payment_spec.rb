# encoding: utf-8
require 'spec_helper'

describe Payment do
  it { should_not have_valid(:amount).when(-1) }
  it { should have_valid(:interest).when(1) }
  it { should_not have_valid(:interest).when(-1) }

  let(:valid_attributes) {
    {
      account_id: 10, account_to_id: 2, exchange_rate: 1,
      amount: 50, interest: 0, reference: 'El primer pago',
      verification: false, date: Date.today
    }
  }

  let(:account_id) { valid_attributes.fetch(:account_id) }
  let(:account_to_id) { valid_attributes.fetch(:account_to_id) }

  it { should have_valid(:date).when('2012-12-12') }
  it { should_not have_valid(:date).when('anything') }
  it { should_not have_valid(:date).when('') }
  it { should_not have_valid(:date).when('2012-13-13') }


  subject { Payment.new(valid_attributes) }

  it "initializes verification false" do
    p = Payment.new

    p.verification.should be_false
    p.amount.should == 0
    p.interest.should == 0
    p.exchange_rate == 1
  end

  context "Invalid" do
    subject { Payment.new }

    it "checks valid presence" do
      subject.should_not be_valid

      [:account_id, :account_to, :account_to_id].each do |met|
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
    let(:account_to) { build :account, id: account_to_id, currency: 'BOB' }

    before(:each) do
      Account.stub!(:find_by_id).with(account_to_id).and_return(account_to)
    end

    it "Valid when" do
      p = Payment.new(valid_attributes)
      p.valid?
      p.should be_valid
    end

  end

end
