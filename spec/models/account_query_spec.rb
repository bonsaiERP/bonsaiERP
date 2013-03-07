require 'spec_helper'

describe AccountQuery do
  it "#bank_cash" do
    active = Account.active
    Account.should_receive(:active).and_return(active)
    ret = Object.new
    ret.should_receive(:includes).with(:moneystore)
    active.should_receive(:where).with(type: ['Cash', 'Bank']).and_return(ret)

    AccountQuery.new.bank_cash
  end

  describe 'options' do
    let(:bank) { build :bank, id: 1 }
    let(:cash) { build :bank, id: 2 }

    it "#bank_cash_options" do
      AccountQuery.any_instance.stub(bank_cash: [bank, cash])

      options = AccountQuery.new.bank_cash_options
      options.first.should eq({})

      options.each_with_index do |val, i|
        next if i == 0
        val.keys.should eq([:id, :type, :currency, :amount, :name, :to_s])
      end
    end

    it "#income_payment_options" do
      AccountQuery.any_instance.stub(
        bank_cash: [build(:bank, id: 1), build(:cash, id: 2)]
      )
      Expense.stub_chain(:approved, where: [build(:expense, id: 3)])

      inc = build(:income, id: 10, contact_id: 100)

      options = AccountQuery.new.income_payment_options(inc)
      options.first.should eq({})

      options.each_with_index do |val, i|
        next if i == 0
        val.keys.should eq([:id, :type, :currency, :amount, :name, :to_s])
      end
    end


    it "#expense_payment_options" do
      AccountQuery.any_instance.stub(
        bank_cash: [build(:bank, id: 1), build(:cash, id: 2)]
      )
      Income.stub_chain(:approved, where: [build(:expense, id: 3)])

      ex = build(:expense, id: 10, contact_id: 100)

      options = AccountQuery.new.income_payment_options(ex)
      options.first.should eq({})

      options.each_with_index do |val, i|
        next if i == 0
        val.keys.should eq([:id, :type, :currency, :amount, :name, :to_s])
      end
    end
  end
end
