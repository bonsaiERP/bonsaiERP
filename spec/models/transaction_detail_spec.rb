require 'spec_helper'

describe TransactionDetail do
  it{ should validate_presence_of(:item_id) }
  it{ should have_valid(:quantity).when(0.1, 1)}
  it{ should_not have_valid(:quantity).when(0)}

  it "calculates total and return data_has" do
    td = TransactionDetail.new(quantity: 2, price: 4, original_price: 4)
    td.total.should eq(8)
    td.subtotal.should eq(8)

    td.data_hash.should eq({
      id: td.id,
      item_id: td.item_id,
      original_price: td.original_price,
      price: td.price,
      quantity: td.quantity,
      subtotal: td.subtotal
    })
  end

  it "indicates change of price" do
    td = TransactionDetail.new(quantity: 2, price: 4, original_price: 1.9)
    td.should be_changed_price
  end

  it "#change_of_item_id" do
    td = TransactionDetail.new(item_id:1, quantity: 2, price: 4)
    td.stub(item: true)
    td.item_id = 2
    td.save.should be_true

    td.item_id = 1
    td.save.should be_false
    td.errors.messages[:item_id].should eq([I18n.t('errors.messages.transaction_details.item_changed')])
  end

  context "Operations related with Income Expense" do
    before(:each) do
      TransactionDetail.any_instance.stub(item: build(:item))
      Income.any_instance.stub(contact: build(:contact), set_client_and_incomes_status: true)
      UserSession.user = build(:user, id: 1)
    end

    let(:attributes) {
      {
      contact_id: 1, date: Date.today, due_date: Date.today, ref_number: 'I-0001', currency: 'BOB',
      income_details_attributes: [{item_id: 1, price: 20, quantity: 10}]
      }
    }

    it "#checks balance" do
      inc = Income.new_income(attributes)
      inc.income_details[0].stub(item: build(:item, for_sale: true))

      inc.save.should be_true

      det = inc.income_details[0]

      det.balance = 5
      det.save.should be_true

      inc = Income.find(inc.id)
      inc.attributes = {income_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 4}] }
      inc.income_details[0].stub(item: build(:item, for_sale: true))

      inc.save.should be_false
      inc.details[0].errors[:item_id].should eq([I18n.t('errors.messages.income_details.balance')])
    end

  end
end
