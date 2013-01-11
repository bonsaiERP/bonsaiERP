# encoding: utf-8
require 'spec_helper'

describe MoneyStore do
  let(:valid_attributes) do
    {amount: 100, currency: 'BOB', name: 'First account'}
  end

  it { should validate_presence_of(:currency) }
  it { should validate_numericality_of(:amount) }

  it { should have_one(:account) }

  it "sets amount before validating" do
    ms = MoneyStore.new
    ms.amount.should
    ms.valid?
    ms.amount.should == 0
  end

  it "checks the relation" do
    ms = MoneyStore.new

    # Can be used reflections also
    ac = ms.association(:account)
    ac.options.fetch(:autosave).should be_true
    ac.options.fetch(:dependent).should eq(:destroy)
    ac.options.fetch(:inverse_of).should eq(:accountable)
  end

  context "Creation" do
    
    it "Creates a new Account" do
      ms = MoneyStore.create!(valid_attributes)
      
      ms.account.should be_persisted
      ms.account.original_type.should eq('MoneyStore')
      ms.account_name.should eq('First account')
      ms.account.amount.should == 100
      ms.account.currency.should eq('BOB')
    end
  end

end
