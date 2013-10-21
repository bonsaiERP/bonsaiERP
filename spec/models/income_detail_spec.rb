require 'spec_helper'

describe IncomeDetail do
  it { should belong_to(:income) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:item) }
  let(:income) { Income.new }

  context 'Validate correct income_item' do
    let(:item) {
      build :item, id: 1, for_sale: true, stockable: true, active: true
    }

    it "Item For sale" do
      id = IncomeDetail.new(item_id: item.id, price: 10, quantity: 1, account_id: 1)
      id.stub(item: item, income: income)

      id.should be_valid
      id.errors_on(:item_id).should be_empty
    end


    it "Not for sale" do
      item.for_sale = false
      id = IncomeDetail.new(item_id: item.id, price: 10, quantity: 1,  account_id: 1)
      id.stub(item: item, income: income)

      id.should_not be_valid
      id.errors_on(:item_id).should_not be_empty
    end

    it "whe income_detail.item_id doesn't change but item.for_sale = false" do
      id = IncomeDetail.new(item_id: item.id, price: 10, quantity: 1,  account_id: 1)
      id.stub(item: item, income: income)

      id.save.should be_true

      id.item.for_sale = false
      id.item.should_not be_for_sale

      id.should be_valid
    end
  end
end
