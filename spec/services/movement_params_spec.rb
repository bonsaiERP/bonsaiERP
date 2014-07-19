require 'spec_helper'

describe MovementParams do
  subject { MovementParams.new }

  it "params income" do
    subject.income.should eq([
      :date, :contact_id, :currency, :exchange_rate, :project_id,
      :description, :due_date, :total,
      :direct_payment, :account_to_id, :reference, :tax_id, :tax_in_out,
      { tag_ids: [] },
      { income_details_attributes: [:id, :item_id, :price, :quantity, :_destroy] }])
  end

  it "params expense" do
    subject.expense.should eq([
      :date, :contact_id, :currency, :exchange_rate, :project_id,
      :description, :due_date, :total,
      :direct_payment, :account_to_id, :reference, :tax_id, :tax_in_out,
      { tag_ids: [] },
      { expense_details_attributes: [:id, :item_id, :price, :quantity, :_destroy]}])
  end

  it "params quick" do
    subject.quick.should eq([:account_to_id, :contact_id, :amount, :date, :reference])
  end
end
