# encoding: utf-8
require 'spec_helper'

describe DefaultTransaction do
  let(:transaction) { Transaction.new }

  it "initializes with Transaction class" do
    DefaultTransaction.new(Income.new)

    expect { DefaultTransaction.new(Item.new) }.should raise_error
  end

  context "Default init" do

    subject{ DefaultTransaction.new(transaction) }

    it { transaction.should be_is_a(Transaction) }
  end
end
