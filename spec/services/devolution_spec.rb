# encoding: utf-8
require 'spec_helper'

describe Devolution do

  let(:valid_attributes) {
    {
      account_id: 10, account_to_id: 2, exchange_rate: 1,
      amount: 50, reference: 'El primer pago',
      verification: false, date: Date.today
    }
  }

  let(:account_id) { valid_attributes.fetch(:account_id) }
  let(:account_to_id) { valid_attributes.fetch(:account_to_id) }

  context 'Validations' do
    it { should validate_presence_of(:account_id) }
    it { should validate_presence_of(:account_to_id) }
    it { should validate_presence_of(:reference) }
    it { should validate_presence_of(:date) }

    it { should have_valid(:date).when('2012-12-12', Date.today, Time.now, '2013/01/25') }
    it { should_not have_valid(:date).when('anything', '', '2012-13-13', nil) }

    it { should_not have_valid(:amount).when(-1, -0.01, '', 'da') }

    context "account_to" do
      let(:account_to) { build :account, id: account_to_id, currency: 'BOB', amount: 500 }

      it "Not valid" do
        dev = Devolution.new(valid_attributes)
        dev.should_not be_valid
        dev.errors[:account_to].should_not be_empty
      end

      it "Valid" do
        Account.stub(:where).with(id: account_to_id).and_return([account_to])
        dev = Devolution.new(valid_attributes)
        dev.stub(movement: build(:income, total: 100, balance: 10 ))
        dev.should be_valid

        dev.amount = 0.01
        dev.should be_valid

        dev.amount = -1
        dev.should_not be_valid
      end
    end

  end

  subject { Devolution.new(valid_attributes) }

  it "initializes verification false" do
    dev = Devolution.new

    dev.verification.should eq(false)
    dev.amount.should == 0
    dev.exchange_rate == 1
  end

  it "initalizes verfication" do
    dev = Devolution.new(verification: "jajaja")
    dev.verification.should eq(false)

    dev = Devolution.new(verification: "11")
    dev.verification.should eq(false)

    dev = Devolution.new(verification: "01")
    dev.verification.should eq(false)

    dev = Devolution.new(verification: "1")
    dev.verification.should eq(true)

    dev = Devolution.new(verification: "true")
    dev.verification.should_not eq(false)
  end

  it "does not have interest" do
    dev = Devolution.new
    expect { dev.interest }.to raise_error
  end

  context "Invalid" do
    subject { Devolution.new }

    it "checks valid presence" do
      subject.should_not be_valid

      [:account_id, :account_to, :account_to_id].each do |met|
        subject.errors[met].should_not be_blank
      end
    end
  end

end
