# encoding: utf-8
require 'spec_helper'

describe ConciliateAccount do
  it "only allow account ledgers" do
    expect { ConciliateAccount.new(Object.new) }.to raise_error
  end

  describe 'Conciliation' do
    before(:each) do
      UserSession.user = build :user, id: 1
    end

    it "does not conciliate null AccountLedger" do
      ledger = build :account_ledger, active: false
      con = ConciliateAccount.new(ledger)

      con.conciliate.should be_false
    end

    it "conciliate!" do
      AccountLedger.any_instance.stub(save: true)
      Account.any_instance.stub(save: true)

      ac1 = build :cash, id: 1
      ac2 = build :income, id: 2

      ledger = AccountLedger.new(amount: 100, currency: 'BOB')
      ledger.stub(account: ac1, account_to: ac2)

      ConciliateAccount.new(ledger)
    end

    context 'Income' do
      it "update only the account_to for Income" do
        income = build :income, id: 10, total: 300, currency: 'BOB'
        cash = build :cash, id: 2, amount: 10

        al = AccountLedger.new(operation: 'payin', id: 10, amount: 100, conciliation: false)
        # stubs
        cash.should_receive(:save).and_return(true)
        al.should_receive(:save).and_return(true)

        al.account = income
        al.account_to = cash

        al.should_not be_conciliation

        ConciliateAccount.new(al).conciliate.should be_true

        al.should be_conciliation
        al.account.amount.should == 300
        al.account_to_amount.should == 10 + 100

        al.approver_id.should eq(1)
        al.approver_datetime.should be_is_a(Time)
      end

      it "updates both accounts for  Bank and Cash" do
        cash = build :cash, amount: 2000, currency: 'USD'
        bank = build :bank, amount: 100, currency: 'BOB'

        al = AccountLedger.new(currency: 'USD', amount: 200, exchange_rate: 7, inverse: false)
        al.account = cash
        al.account_to = bank
        # stubs
        cash.should_receive(:save).and_return(true)
        bank.should_receive(:save).and_return(true)
        al.should_receive(:save).and_return(true)

        ConciliateAccount.new(al).conciliate.should be_true

        al.account_amount.should == 1800.0
        al.account_to_amount.should == 100 + 200 * 7

        al.approver_id.should eq(1)
      end

      it "Only updates only the ledger when service payment" do
        income = build :income, id: 10, total: 100, currency: 'BOB'
        expense = build :expense, id: 2, amount: 50, total: 10

        al = AccountLedger.new(operation: 'payin', id: 10, amount: 100, conciliation: false)
        # stubs
        al.should_receive(:save).and_return(true)

        al.account = income
        al.account_to = expense
        al.should_not be_conciliation
        al.approver_id.should be_nil
        al.approver_datetime.should be_nil

        ConciliateAccount.new(al).conciliate.should be_true

        al.should be_conciliation
        # Account don't change
        al.account.amount.should == 100
        al.account_to_amount.should == 50

        al.approver_id.should eq(1)
        al.approver_datetime.should be_is_a(Time)
      end
    end
  end
end
