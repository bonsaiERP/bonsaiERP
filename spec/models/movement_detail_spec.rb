require 'spec_helper'

describe MovementDetail do
  it{ should validate_presence_of(:item_id) }
  it{ should have_valid(:quantity).when(0.1, 1)}
  it{ should_not have_valid(:quantity).when(0)}

  it "calculates total and return data_has" do
    td = MovementDetail.new(quantity: 2, price: 4, original_price: 4)
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
    td = MovementDetail.new(quantity: 2, price: 4, original_price: 1.9)
    td.should be_changed_price
  end

  it "#change_of_item_id" do
    td = MovementDetail.new(item_id:1, quantity: 2, price: 4)
    td.stub(item: true)
    td.item_id = 2
    td.save.should eq(true)

    td.item_id = 1
    td.save.should eq(false)
    td.errors.messages[:item_id].should eq([I18n.t('errors.messages.movement_details.item_changed')])
  end

  context "Operations related with Income Expense" do
    before(:each) do
      MovementDetail.any_instance.stub(item: build(:item))
      Income.any_instance.stub(contact: build(:contact), set_client_and_incomes_status: true)
      UserSession.user = build(:user, id: 1)
    end

    let(:today) { Time.zone.now.to_date }

    let(:attributes) {
      {
      contact_id: 1, date: today, due_date: today, ref_number: 'I-0001', currency: 'BOB', state: 'draft',
      income_details_attributes: [{item_id: 1, price: 20, quantity: 10}]
      }
    }

    it "#checks balance" do
      inc = Income.new(attributes)
      inc.income_details[0].stub(item: build(:item, for_sale: true))

      inc.save.should eq(true)

      det = inc.income_details[0]

      det.balance = 5
      det.save.should eq(true)

      inc = Income.find(inc.id)
      inc.attributes = {income_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 4}] }
      inc.income_details[0].stub(item: build(:item, for_sale: true))

      inc.save.should eq(false)
      inc.details[0].errors[:item_id].should eq([I18n.t('errors.messages.income_details.balance')])
    end

    it "#valid_for_destruction" do
      inc = Income.new(attributes)
      inc.income_details[0].stub(item: build(:item, for_sale: true))
      inc.save.should eq(true)
      det = inc.income_details[0]
      det.balance = 8
      det.save.should eq(true)

      attrs = attributes.merge(
        income_details_attributes: [{item_id: 1, price: 20, quantity: 10, _destroy: '1', id: det.id}]
      )
      inc = Income.find(inc.id)
      inc.attributes = attrs
      inc.income_details[0].should be_marked_for_destruction

      inc.save.should eq(false)
      inc.income_details[0].should_not be_marked_for_destruction
      inc.income_details[0].errors[:item_id].should eq([I18n.t('errors.messages.movement_details.not_destroy')])
    end

  end

end
