require 'spec_helper'

describe TransactionParams do
  subject { TransactionParams.new }

  it "params income" do
    subject.income.should eq([
      :date, :contact_id, :currency, :exchange_rate, :project_id, 
      :description, :due_date, :total,
      :direct_payment, :account_to_id, :reference,
      income_details_attributes: [:id, :item_id, :price, :quantity, :_destroy]])
  end

  it "params expense" do
    subject.expense.should eq([
      :date, :contact_id, :currency, :exchange_rate, :project_id, 
      :description, :due_date, :total,
      :direct_payment, :account_to_id, :reference,
       expense_details_attributes: [:id, :item_id, :price, :quantity, :_destroy]])
  end

  it "params quick" do
    subject.quick.should eq([:account_to_id, :contact_id, :amount, :date, :reference])
  end
end
