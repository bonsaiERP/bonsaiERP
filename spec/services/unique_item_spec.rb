require 'spec_helper'

describe UniqueItem do
  let(:income) { build :income }

  it "#valid true" do
    income.income_details.build(item_id: 1, quantity: 2)
    income.income_details.build(item_id: 2, quantity: 2)

    UniqueItem.new(income).should be_valid
    income.items.should have(2).items
  end

  it "#valid false" do
    income.income_details.build(item_id: 1, quantity: 2)
    income.income_details.build(item_id: 2, quantity: 2)
    income.income_details.build(item_id: 1, quantity: 3)
    income.income_details.build(item_id: 3, quantity: 1)
    income.income_details.build(item_id: 3, quantity: 4)

    UniqueItem.new(income).should_not be_valid
    income.errors[:base].should eq([I18n.t("errors.messages.item.repeated_items")])
    income.items[2].errors[:item_id].should eq([I18n.t("errors.messages.item.repeated")])
    income.items[4].errors[:item_id].should eq([I18n.t("errors.messages.item.repeated")])

  end
end
