require 'spec_helper'

describe Loans::GiveForm do
  before(:each) do
    UserSession.user = build :user, id: 1
  end

  let(:cash) { create :cash, currency: 'BOB', amount: 0 }
  let(:attributes) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1, description: 'Hi'
    }
  end

  before(:each) do
    Loans::Give.any_instance.stub(contact: build(:contact, id: 10))
  end

  it "#create" do
    lf = Loans::GiveForm.new(attributes.merge(account_to_id: cash.id))

    # loan
    lf.create.should eq(true)

    lf.loan.should be_is_a(Loans::Give)
    lf.loan.amount.should == attributes.fetch(:total)
    lf.loan.date.should eq(attributes.fetch(:date))
    lf.loan.due_date.should eq(attributes.fetch(:due_date))
    lf.loan.creator_id.should eq(1)

    attributes.except(:reference).each do |k, v|
      lf.loan.send(k).should eq(v)
    end

    # ledger
    lf.ledger.amount.should == -100
    expect(lf.ledger.operation).to eq('lgcre')
    expect(lf.ledger.contact_id).to be_present
    expect(lf.ledger.contact_id).to eq(lf.loan.contact_id)

    cash.reload
    cash.amount.should == -100
  end

  it "#create other currency" do
    cash2 = create :cash, currency: 'USD', amount: 100
    lf = Loans::GiveForm.new(attributes.merge(account_to_id: cash2.id, exchange_rate: 7))

    # loan
    lf.create.should eq(true)

    lf.loan.should be_is_a(Loans::Give)
    lf.loan.currency.should eq('USD')
    lf.loan.exchange_rate.should == 7.0
    lf.loan.amount.should == attributes.fetch(:total)
    lf.loan.date.should eq(attributes.fetch(:date))
    lf.loan.due_date.should eq(attributes.fetch(:due_date))
    # ledger
    lf.ledger.amount.should == -100
    lf.ledger.contact_id.should eq(lf.contact_id)
    expect(lf.ledger.operation).to eq('lgcre')

    cash2.reload
    cash2.amount.should == 0
  end
end

