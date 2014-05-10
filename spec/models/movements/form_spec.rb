require 'spec_helper'

describe Movements::Form do
  it "Expense::Form#form_details_data NEW" do
    exp = Expenses::Form.new_expense
    exp.details.should_not_receive(:includes).with(:item)

    exp.form_details_data
  end

  it "Expense::Form#form_details_data EDIT" do
    exp = Expenses::Form.new_expense
    exp.movement.stub(new_record?: false)
    exp.details.should_receive(:includes).with(:item).and_return([])

    exp.form_details_data
  end
end
