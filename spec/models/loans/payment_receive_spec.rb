require 'spec_helper'

describe Loans::PaymentReceive do
  #it { should validate_presence_of(:account_to_id) }

  let(:loan_attr) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1
    }
  end

  context 'payment' do
    let(:cash) { create :cash, currency: 'BOB', amount: 0 }
    let(:contact) { build :contact, id: 1 }

    let(:attributes) do
      {
        account_to_id: cash.id, date: Date.today, reference: 'Pay 23233',
        date: Date.today, amount: 50, exchange_rate: 1
      }
    end

    before(:each) {
      UserSession.user = build :user, id: 1
      OrganisationSession.organisation = build :organisation, currency: 'BOB'
      Loans::Receive.any_instance.stub(contact: contact)
    }

    it "pays Loan" do
      lf = Loans::Form.new_receive(loan_attr.merge(account_to_id: cash.id))

      lf.create.should be_true
      lf.loan.should be_persisted
      lf.loan.amount.should == 100
      lf.loan.total.should == 100
      lf.loan.ledger_in.should be_is_a(AccountLedger)
      cash.reload.amount.should == 100

      lp = Loans::PaymentReceive.new(attributes.merge(account_id: lf.loan.id))

      lp.create_payment.should be_true
      lp.ledger.amount.should == -50

      loan = Loans::Receive.find(lf.loan.id)
      loan.amount.should == 50

      c = Cash.find(cash.id)
      c.amount.should == 50

      lp = Loans::PaymentReceive.new(attributes.merge(account_id: lf.loan.id, amount: 60))
      lp.create_payment.should be_false
      lp.errors[:amount].should eq([I18n.t('errors.messages.less_than_or_equal_to', count: 50.0)])
      # Pay with other currency
      bank = create :bank, currency: 'USD', amount: 0

      lp = Loans::PaymentReceive.new(attributes.merge(account_id: lf.loan.id, amount: 25, account_to_id: bank.id, exchange_rate: 2))

      lp.create_payment.should be_true
      loan = Loans::Receive.find(loan.id)

      loan.amount.should == 0
      loan.should be_is_paid
    end


    it "pays interest" do
      lf = Loans::Form.new_receive(loan_attr.merge(account_to_id: cash.id))

      lf.create.should be_true
      lf.loan.should be_persisted
      lf.loan.ledger_in.should be_is_a(AccountLedger)
      cash.reload.amount.should == 100

      lp = Loans::PaymentReceive.new(attributes.merge(account_id: lf.loan.id))

      lp.create_interest.should be_true
      lp.ledger.amount.should == -50

      c = Cash.find(cash.id)
      c.amount.should == 50
    end
  end

end
