# encoding: utf-8
require 'spec_helper'

describe NullAccount do
  it "only allow account ledgers" do
    expect { NullAccount.new(Object.new) }.to raise_error

    NullAccount.new(build :account_ledger)
  end

  it "only nulls active and not conciliated accounts_ledgers" do
    ledger = build :accounts_ledger, conciliation: true, active: true
    
    # Conciliated
    na = NullAccount.new(ledger)
    na.null.should be_false
    
    # Nulled inactive
    ledger.active = false
    ledger.conciliation = false

    na = NullAccount.new(ledger)
    na.null.should be_false

    # Nulled inactive
    ledger.active = true
    ledger.conciliation = false
    na = NullAccount.new(ledger)
    na.null.should be_true
  end

  describe 'Null Income/Expense' do
    before do
      UserSession.user = build :user, id: 1
    end

    it "nulls a expense" do
      
    end

  end
end

