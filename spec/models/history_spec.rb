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
      expect(Expense.details_col).to eq(:expense_details)
      expect(Expense.state_col).to eq(:state)
      expect(Expense.due_date_col).to eq(:due_date)

      expect(Income.details_col).to eq(:income_details)
    end

    it "#null due_date" do
      e = Expense.new(attributes.merge(due_date: nil))
      e.save(validate: false).should be_true

      e.state = 'nulled'
      e.save(validate: false).should be_true

      expect(e.histories).to have(2).items
      h = e.histories.first
      expect(h.history_data[:state]).to eq({from: 'approved', to: 'nulled'})
    end

    it "#history" do
      # Create
      e = Expense.new(attributes)
      e.save.should be_true

      expect(e.histories).to have(1).item
      h = e.histories.first
      expect(h.klass_type).to eq('Expense')

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
      expect(h.klass_type).to eq('Expense')

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

      h = e.histories.first.history_data
      h[:expense_details][0][:destroyed].should be_true
      h[:expense_details][0][:index].should eq(2)
      h[:expense_details][0][:item_id].should eq(10)
      h[:expense_details][0][:price].should == "10.0"
      h[:expense_details][0][:quantity].should == "2.0"
    end

    it "#state" do
      # Create
      d = 1.day.ago.to_date
      e = Expense.new(attributes.merge(date: d, due_date: d))
      e.save.should be_true

      e.should be_is_approved
      # Update and check due date
      today = Date.today
      e.due_date = today
      e.save.should be_true

      expect(e.histories).to have(2).items
      h = e.histories.first
      h.history_data[:due_date].should eq( { from: d, to: today })
      h.history_data[:state].should eq( {from: 'due', to: 'approved'} )
    end
  end
end
