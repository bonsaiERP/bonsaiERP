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
    end
  end
end
