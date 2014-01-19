require 'spec_helper'

describe History do
  it { should belong_to(:historiable) }

  context 'Simple history' do
    before(:each) do
      UserSession.user = build :user, id: 1
      Item.any_instance.stub(unit: build(:unit))
      Item.send(:include, Models::History)
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
      expect(h.history_data['price']).to eq({'was' => '10.0', 'is' => '20.0', 'type' => 'BigDecimal'})
      expect(h.history_data['buy_price']).to eq({'was' => '7.0', 'is' => '15.0', 'type' => 'BigDecimal'})
      expect(h.history_data['name']).to eq({'was' => 'item', 'is' => 'New name for item', 'type' => 'String'})

      # Latest
      expect(i.histories.last).to be_new_item
      expect(i.histories.last.user_id).to eq(1)
    end
  end
end
