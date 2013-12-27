# encoding: utf-8
require 'spec_helper'

describe MoneyStore do
  it { should belong_to(:bank) }
  it { should belong_to(:cash) }

  # MoneyStore not needed using Hstore from Postgresql
  #it "tests the belongs_to relationships" do
  #  bank = build :bank
  #  bank.build_money_store
  #  bank.save.should be_true

  #  bank.money_store_id.should eq(bank.money_store.id)

  #  ms = MoneyStore.find(bank.money_store_id)
  #  ms.bank.should eq(bank)
  #  ms.cash.should be_nil
  #end
end
