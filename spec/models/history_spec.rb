require 'spec_helper'

describe History do
  it { should belong_to(:historiable) }

  context 'Simple history' do
    before(:each) do
      UserSession.user = build :user, id: 1
      Item.any_instance.stub(unit: build(:unit))
    end

    it "#create" do
      i = create :item, unit_id: 1
      i.should be_persisted
      i.histories.should have(1).item

      h = i.histories.first
      h.should be_persisted
      h.should be_new_item
      h.created_at.should be_is_a(Time)
    end

    it "#update" do
      i = create :item, name: 'item', unit_id: 1, price: 10, buy_price: 7


      i.update_attributes(
         price: 20, buy_price: 15, name: 'New name for item'
      ).should be_true

      i = Item.find(i.id)
      i.histories.should have(2).items
      h = i.histories.first
      expect(h).not_to be_new_item

      expect(h.user_id).to eq(1)
      expect(h.history_attributes).to eq([:price, :buy_price, :name])

      expect(h.history_data[:price]).to eq({ from: '10.0'.to_d, to: '20.0'.to_d})
      expect(h.history_data[:buy_price]).to eq({ from: '7.0'.to_d, to: '15.0'.to_d })
      expect(h.history_data[:name]).to eq({ from: 'item', to: 'New name for item' })


      # Latest
      expect(i.histories.last).to be_new_item
      expect(i.histories.last.user_id).to eq(1)

      expect(i.update_attributes(active: false)).to be_true
      i.histories.should have(3).items
      h = i.histories.first
      expect( h.history_attributes ).to eq([:active])
      expect(h.history_data).to eq( {active: { from: true, to: false } } )
    end

  end

  context 'History with details' do
    let(:item) { build :item, id: 1 }
    let(:contact) { build :contact, id: 1 }

    let(:details) {
      [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
       {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
      ]
    }
    let(:today) { Date.today }
    let(:attributes) {
      {
      date: today, due_date: today, contact_id: 1, name: 'E-14-0001',
      currency: 'BOB', description: "New expense description",
      state: 'approved', expense_details_attributes: details
      }
    }

    before(:each) do
      UserSession.user = build :user, id: 1
      Expense.any_instance.stub(contact: contact)
      ExpenseDetail.any_instance.stub(item: item)
    end

    it "#history_details" do
      expect(Expense.history_details).to eq(:expense_details)
      expect(Income.history_details).to eq(:income_details)
    end

    it "#history" do
      # Create
      e = Expense.new(attributes)
      e.save.should be_true

      expect(e.histories).to have(1).item

      # Update detail
      det = e.expense_details.map { |v| v.attributes.except('created_at', 'updated_at', 'original_price') }
      det[0]['price'] = 15
      det[0]['description'] = 'A new description'

      at = e.attributes
      .merge('description' => 'Jo jo jo', 'expense_details_attributes' => det)
      .except('created_at', 'updated_at')

      expect(e.update_attributes(at)).to be_true

      expect(e.histories).to have(2).items
      h = e.histories.first


      expect(h.history_data[:description]).to eq({from: 'New expense description', to: 'Jo jo jo'})
      det_hist = h.history_data[:expense_details][0]
      expect(det_hist[:price]).to eq({from: '10'.to_d, to: '15'.to_d})

      expect(det_hist[:description]).to eq({from: 'First item', to: 'A new description'})

      expect(det_hist[:id]).to be_a(Integer)

      at['expense_details_attributes'] << { item_id: 10, price: 10, quantity: 2, balance: 2 }

      # Update add new detail
      expect(e.update_attributes(at)).to be_true
      expect(e.histories).to have(3).items
      h = e.histories.first

      expect(h.history_data).to eq({:expense_details=>[{:index=>2, :new_record=>true}]})

      # Update delete detail
      det = e.expense_details.map { |v| v.attributes.except('created_at', 'updated_at', 'original_price') }
      det[2]['_destroy'] = '1'

      at = e.attributes.except('created_at', 'updated_at').merge(expense_details_attributes: det)
      e.update_attributes(at).should be_true

      expect(e.expense_details).to have(2).items

    end
  end
end
