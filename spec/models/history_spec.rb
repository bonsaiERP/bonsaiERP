require 'spec_helper'

describe History do
  it { should belong_to(:historiable) }

  context 'Cases' do
    before(:each) do
      UserSession.user = build :user, id: 1
      Item.any_instance.stub(unit: build(:unit))
    end

    it "#create" do
      i = create :item, unit_id: 1
      i.should be_persisted
      i.histories.size.should eq(1)

      h = i.histories.first
      h.should be_persisted
      h.should be_new_item
      h.klass_to_s.should eq(i.to_s)
      h.created_at.should be_is_a(Time)
    end

    it "#update" do
      i = create :item, name: 'item', unit_id: 1, price: 10, buy_price: 7


      i.update(
         price: 20, buy_price: 15, name: 'New name for item'
      ).should eq(true)

      i = Item.find(i.id)
      i.histories.size.should eq(2)
      h = i.histories.first
      expect(h).not_to be_new_item

      expect(h.user_id).to eq(1)
      expect(h.history_attributes.sort).to eq(%w(price buy_price name updated_at).sort)

      expect(h.history['price']).to eq({ from: '10.0'.to_d, to: '20.0'.to_d, type: 'decimal'})
      expect(h.history['buy_price']).to eq({ from: '7.0'.to_d, to: '15.0'.to_d, type: 'decimal' })
      expect(h.history['name']).to eq({ from: 'item', to: 'New name for item', type: 'string' })


      # Latest
      expect(i.histories.last).to be_new_item
      expect(i.histories.last.user_id).to eq(1)

      expect(i.update_attributes(active: false)).to eq(true)
      i.histories.size.should eq(3)
      h = i.histories.first
      expect( h.history_attributes.sort ).to eq(['active', 'updated_at'])
      expect(h.history['active']).to eq( { from: true, to: false, type: 'boolean' } )
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

    it "#null due_date" do
      e = Expense.new(attributes.merge(due_date: nil))
      e.save(validate: false).should eq(true)

      e.state = 'nulled'
      e.save(validate: false).should eq(true)

      expect(e.histories.size).to eq(2)
      h = e.histories.first
      expect(h.history['state']).to eq({from: 'approved', to: 'nulled', type: 'string'})
    end

    it "#history" do
      # Create
      e = Expense.new(Expense::EXTRAS_DEFAULTS.merge(attributes))
      e.save.should eq(true)

      expect(e.histories.size).to eq(1)
      h = e.histories.first
      expect(h.klass_type).to eq('Expense')
      expect(h.klass_to_s).to eq(e.to_s)

      # Update detail
      det = e.expense_details.map { |v| v.attributes.except('created_at', 'updated_at', 'original_price') }
      det[0]['price'] = 15
      det[0]['description'] = 'A new description'

      #.merge('description' => 'Jo jo jo', 'expense_details_attributes' => det)
      e_data = e.attributes.merge('expense_details_attributes' => det)
      .except('created_at', 'updated_at')

      #e.attributes = e_data
      expect(e.update(e_data)).to eq(true)

      expect(e.histories.size).to eq(2)
      h = e.histories.first
      expect(h.history_data.keys.sort).to eq(['expense_details', 'updated_at'])

      expect(h.history['expense_details']).to eq({})

      expect(h.klass_type).to eq('Expense')
      det_hist = h.all_data['expense_details']
      expect(det_hist[0]['price']).to eq('15.0')
      expect(det_hist[0]['price_was']).to eq('10.0')

      expect(det_hist[0]['description']).to eq('A new description')
      expect(det_hist[0]['description_was']).to eq('First item')
      expect(det_hist[0]['id']).to be_is_a(Integer)

      e_data['expense_details_attributes'] << { item_id: 10, price: 10, quantity: 2, balance: 2 }.stringify_keys
      #tot = at['expense_details_attributes'].inject(0) { |sum, val| val['price'] * val['quantity'] }
      #at['balance_inventory'] = 20.0

      # Update add new detail
      expect(e.update(e_data)).to eq(true)

      expect(e.histories.size).to eq(3)
      h = e.histories.first

      #expect(h.history['balance_inventory']).to eq({from: 1, to: 1, type: :decimal})
      expect(h.history_data["expense_details"]).to eq(true)

      # Update delete detail
      det = e.expense_details.map { |v| v.attributes.except('created_at', 'updated_at', 'original_price') }
      det[2]['_destroy'] = '1'

      at = e.attributes.except('created_at', 'updated_at').merge(expense_details_attributes: det)
      e.update_attributes(at).should eq(true)

      expect(e.histories.size).to eq(4)
      expect(e.expense_details.size).to eq(2)

      h = e.histories.first
      hdet = h.all_data['expense_details']
      hdet[2]['destroyed?'].should eq(true)
      hdet[2]['item_id'].should eq(10)
      hdet[2]['price'].should == "10.0"
      hdet[2]['quantity'].should == "2.0"

      e.save
      expect(e.histories.size).to eq(5)
    end

    it "#state" do
      # Create
      d = 2.days.ago.to_date
      e = Expense.new(attributes.merge(date: d, due_date: d))
      e.save.should eq(true)

      e.should be_is_approved
      # Update and check due date
      today = Date.today
      e.due_date = today
      e.save.should eq(true)

      expect(e.histories.size).to eq(2)
      h = e.histories.first
      h.history['due_date'].should eq( { from: d, to: today, type: 'date' })
      #h.history['state'].should eq( {from: 'due', to: 'approved', type: 'string'} )
      h.history['state'].should be_nil

      d2 = 1.days.ago.to_date
      e.due_date = d2
      e.save.should eq(true)
      h = e.histories.first
      h.history['due_date'].should eq( { from: today, to: d2, type: 'date' })
      #h.history['state'].should eq( {from: 'approved', to: 'due', type: 'string'} )
      h.history['state'].should be_nil
    end
  end
end
