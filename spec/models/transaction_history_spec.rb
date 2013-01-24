require 'spec_helper'

describe TransactionHistory do
  it { should belong_to(:income) }
  it { should belong_to(:user) }

  context "Create an income an check history" do
    let(:contact) {build :contact, id: 10 }
    let(:item1) { build :item, id: 1, price: 10, for_sale: true }
    let(:item2) { build :item, id: 2, price: 20, for_sale: true }

    let(:details) {
      [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
       {item_id: 2, price: 20.0, quantity: 10, description: "Second item"}
      ]
    }
    let(:valid_attributes) do
      {
        ref_number: 'I-13-0001', date: Date.today ,currency: 'BOB', contact_id: 10,
        description: "New income description", state: "draft", total: 300,
        income_details_attributes: details
      }
    end
    let(:item_ids) { details.map {|v| v[:item_id] } }

    let!(:income) do 
      i = Income.new_income(valid_attributes)
      i.stub(contact: contact)
      i.income_details[0].stub(item: item1)
      i.income_details[1].stub(item: item2)
      i.save
      i
    end

    it "creates the first History" do
      income.should be_persisted
      UserSession.user = build :user, id: 12

      th = TransactionHistory.new
      th.create_history(income).should be_true
      th.should be_persisted

      income.total = 290

      #puts th.data
      th.data.should be_is_a(Hash)
      th.data.should_not be_blank
      th.data.fetch(:amount).should eq(300)
      th.data.fetch(:amount).should_not eq(income.total)
      th.data.fetch(:name).should eq(income.name)

      th.data.keys.should include(:name, :amount, :balance, :original_total, :approver_id)

      th.data[:income_details].should have(2).items
      th.data[:income_details].each do |det|
        det.keys.should include(:id, :item_id, :quantity, :price, :original_price)
      end
    end
  end
end
