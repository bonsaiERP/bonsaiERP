# encoding: utf-8
require 'spec_helper'

describe MoneyStore do
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:amount) }

  it { should belong_to(:currency) }
  it { should have_one(:account) }

  it "sets amount before validating" do
    ms = MoneyStore.new
    ms.amount.should
    ms.valid?
    ms.amount.should == 0
  end

end
