require 'spec_helper'

describe Loans::Form do
  let(:attributes) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1
    }
  end

  context 'Loans::Receive' do
    it "$new_receive" do
      lf = Loans::Form.new_receive(attributes)

      # loan
      lf.loan.should be_is_a(Loans::Receive)
      lf.loan.amount.should == attributes.fetch(:total)
      lf.loan.date.should eq(attributes.fetch(:date))
      lf.loan.due_date.should eq(attributes.fetch(:due_date))
      # ledger
      lf.ledger.amount.should == 100
      expect(lf.ledger.operation).to eq('lrcre')
    end

    let(:cash) { create :cash, currency: 'BOB', amount: 0 }
    let(:contact) { build :contact, id: 1 }

    before(:each) {
      UserSession.user = build :user, id: 1
      Loans::Receive.any_instance.stub(contact: contact)
    }


    it "#create" do
      lf = Loans::Form.new_receive(attributes.merge(account_to_id: cash.id))

      lf.create.should be_true
      lf.loan.should be_persisted
      lf.loan.currency.should eq('BOB')
      lf.loan.date.should be_is_a(Date)
      lf.loan.due_date.should be_is_a(Date)

      lf.loan.due_date.should == lf.loan.date + 10.days

      lf.ledger.should be_persisted
      lf.ledger.should be_is_lrcre
      lf.ledger.should be_is_approved
      lf.ledger.should be_persisted

      c = Account.find(cash.id)
      c.amount.should == 100
      c.should be_is_a(Cash)
    end

    it "#create other currency" do
      cash2 = create :cash, currency: 'USD', amount: 0

      lf = Loans::Form.new_receive(attributes.merge(account_to_id: cash2.id))

      lf.create.should be_true
      lf.loan.should be_persisted
      lf.loan.currency.should eq('USD')

      lf.ledger.should be_persisted
      lf.ledger.should be_is_lrcre
      lf.ledger.should be_is_approved
      lf.ledger.should be_persisted

      c = Account.find(cash2.id)
      c.amount.should == 100
      c.should be_is_a(Cash)
    end
  end

  context 'Loans::Give' do
    let(:cash) { create :cash, currency: 'BOB', amount: 0 }
    let(:contact) { build :contact, id: 1 }

    before(:each) {
      UserSession.user = build :user, id: 1
      Loans::Give.any_instance.stub(contact: contact)
    }

    it "$new_give" do
      lf = Loans::Form.new_give(attributes)

      # loan
      lf.loan.should be_is_a(Loans::Give)
      lf.loan.amount.should == attributes.fetch(:total)
      lf.loan.date.should eq(attributes.fetch(:date))
      lf.loan.due_date.should eq(attributes.fetch(:due_date))
      # ledger
      lf.ledger.amount.should == -100
      expect(lf.ledger.operation).to eq('lgcre')
    end

    it "#create" do
      lf = Loans::Form.new_give(attributes.merge(account_to_id: cash.id))

      lf.create.should be_true
      lf.loan.should be_persisted

      lf.ledger.should be_persisted
      lf.ledger.should be_is_lgcre
      lf.ledger.should be_is_approved
      lf.ledger.should be_persisted


      c = Account.find(cash.id)
      c.amount.should == -100
      c.should be_is_a(Cash)
    end
  end
end
