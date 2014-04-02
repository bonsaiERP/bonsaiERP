require 'spec_helper'

describe Accounts::Query do
  it "#money" do
    active = Account.active

    Account.should_receive(:active).and_return(active)
    ret = Object.new
    ret.should_receive(:order).with(:type, :name)

    active.should_receive(:where).with(type: %w(Bank Cash StaffAccount)).and_return(ret)

    Accounts::Query.new.money
  end

  describe 'options' do
    let(:bank) { build :bank, id: 1 }
    let(:cash) { build :bank, id: 2 }

    it "#money_options" do
      Accounts::Query.any_instance.stub(money: [bank, cash])

      options = Accounts::Query.new.money_options
      options.first.should eq({})

      options.each_with_index do |val, i|
        next if i == 0
        val.keys.should eq([:id, :type, :currency, :amount, :name, :to_s, :text])
      end
    end

    #it "#income_payment_options" do
      ##Accounts::Query.any_instance.stub(
      ##  bank_cash: [build(:bank, id: 1), build(:cash, id: 2)]
      ##)
      #UserSession.user = build :user, id: 1
      #create :bank, id: 1
      #create :cash, id: 2

      #Expense.stub_chain(:approved, where: [build(:expense, id: 3)])

      #inc = build(:income, id: 10, contact_id: 100)

      #options = Accounts::Query.new.income_payment_options(inc)
      #options.first.should eq({})

      #options.each_with_index do |val, i|
        #next if i == 0
        #val.keys.should eq([:id, :type, :currency, :amount, :name, :to_s])
      #end
    #end


    #it "#expense_payment_options" do
      #Accounts::Query.any_instance.stub(
        #bank_cash: [build(:bank, id: 1), build(:cash, id: 2)]
      #)
      #Income.stub_chain(:approved, where: [build(:expense, id: 3)])

      #ex = build(:expense, id: 10, contact_id: 100)

      #options = Accounts::Query.new.income_payment_options(ex)
      #options.first.should eq({})

      #options.each_with_index do |val, i|
        #next if i == 0
        #val.keys.should eq([:id, :type, :currency, :amount, :name, :to_s])
      #end
    #end

  end
end
