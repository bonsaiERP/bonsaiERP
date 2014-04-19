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
      h.klass_to_s.should eq(i.to_s)
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
      expect(h.history_attributes).to eq(%w(price buy_price name))

      expect(h.history['price']).to eq({ from: '10.0'.to_d, to: '20.0'.to_d, type: 'decimal'})
      expect(h.history['buy_price']).to eq({ from: '7.0'.to_d, to: '15.0'.to_d, type: 'decimal' })
      expect(h.history['name']).to eq({ from: 'item', to: 'New name for item', type: 'string' })


      # Latest
      expect(i.histories.last).to be_new_item
      expect(i.histories.last.user_id).to eq(1)

      expect(i.update_attributes(active: false)).to be_true
      i.histories.should have(3).items
      h = i.histories.first
      expect( h.history_attributes ).to eq(['active'])
      expect(h.history).to eq( {'active' => { from: true, to: false, type: 'boolean' } } )
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
      e.save(validate: false).should be_true

      e.state = 'nulled'
      e.save(validate: false).should be_true

      expect(e.histories).to have(2).items
      h = e.histories.first
      expect(h.history['state']).to eq({from: 'approved', to: 'nulled', type: 'string'})
    end

    it "#history" do
      # Create
      e = Expense.new(attributes)
      e.save.should be_true

      expect(e.histories).to have(1).item
      h = e.histories.first
      expect(h.klass_type).to eq('Expense')
      expect(h.klass_to_s).to eq(e.to_s)

      # Update detail
      det = e.expense_details.map { |v| v.attributes.except('created_at', 'updated_at', 'original_price') }
      det[0]['price'] = 15
      det[0]['description'] = 'A new description'

      #.merge('description' => 'Jo jo jo', 'expense_details_attributes' => det)
      at = e.attributes
      .merge('expense_details_attributes' => det)
      .except('created_at', 'updated_at')


     $test = true
      expect(e.update_attributes(at)).to be_true

      expect(e.histories).to have(2).items
      h = e.histories.first
      #expect(h.history_data['description']).to eq({'from' => 'New expense description', 'to' => 'Jo jo jo', 'type' => 'text'})
      expect(h.klass_type).to eq('Expense')
      det_hist = h.history_data['expense_details']
      expect(det_hist[0]['price']).to eq({'from' => '10.0', 'to' => '15.0', 'type' => 'decimal'})

      expect(det_hist[0]['description']).to eq({'from' => 'First item', 'to' => 'A new description', 'type' => 'string'})
      expect(det_hist[0]['id']).to be_is_a(Integer)

      at['expense_details_attributes'] << { item_id: 10, price: 10, quantity: 2, balance: 2 }

      # Update add new detail
      $test = 1
      expect(e.update_attributes(at)).to be_true
      expect(e.histories).to have(3).items
      h = e.histories.first

      expect(h.history_data).to eq({ 'expense_details' => [{ 'new_record' => true, 'index' => 2 }] })

      # Update delete detail
      det = e.expense_details.map { |v| v.attributes.except('created_at', 'updated_at', 'original_price') }
      det[2]['_destroy'] = '1'

      at = e.attributes.except('created_at', 'updated_at').merge(expense_details_attributes: det)
      e.update_attributes(at).should be_true

      expect(e.histories).to have(4).items
      expect(e.expense_details).to have(2).items

      h = e.histories.first.history_data

      h['expense_details'][0]['destroyed'].should be_true
      h['expense_details'][0]['index'].should eq(2)
      h['expense_details'][0]['item_id'].should eq(10)
      h['expense_details'][0]['price'].should == "10.0"
      h['expense_details'][0]['quantity'].should == "2.0"

      e.save
      expect(e.histories).to have(5).items
    end

    it "#state" do
      # Create
      d = 2.days.ago.to_date
      e = Expense.new(attributes.merge(date: d, due_date: d))
      e.save.should be_true

      e.should be_is_approved
      # Update and check due date
      today = Date.today
      e.due_date = today

      e.save.should be_true

      expect(e.histories).to have(2).items
      h = e.histories.first

      h.history['due_date'].should eq( { from: d, to: today, type: 'date' })
      h.history['state'].should eq( {from: 'due', to: 'approved', type: 'string'} )

      d2 = 1.days.ago.to_date
      e.due_date = d2
      e.save.should be_true
      h = e.histories.first
      h.history['due_date'].should eq( { from: today, to: d2, type: 'date' })
      h.history['state'].should eq( {from: 'approved', to: 'due', type: 'string'} )
    end
  end

  describe "test different convertions" do
    let(:subject) { History.new }

    it "date" do
      d = {'date' => {"from"=>"2014-04-17", "to"=>"2014-04-19", "type"=>"date"} }

      subject.history_data = d
      subject.history.should eq(
        { 'date' => { from: Date.parse('2014-04-17'), to: Date.parse('2014-04-19'), type: 'date' } }
      )
    end

    it "time" do
      t = {'date' => {"from"=>"2014-04-19T14:46:12-04:00",
                      "to"=>"2014-04-19T14:46:52-04:00", "type"=>"datetime"} }

      subject.history_data = t
      subject.history.should eq({
        'date' => {
          from: DateTime.parse('2014-04-19T14:46:12-04:00'),
          to: DateTime.parse('2014-04-19T14:46:52-04:00'), type: 'datetime'
        }
      })
    end

    it "decimal" do
      num = { 'num' => {'from' => '12.3' , 'to' => '14.5', 'type' => 'decimal'} }
      subject.history_data = num

      expect(subject.history).to eq({
        'num' => { from: BigDecimal.new('12.3'), to: BigDecimal.new('14.5'), type: 'decimal' }
      })
    end

  end

end
