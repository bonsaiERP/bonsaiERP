require 'spec_helper'

describe Price do

  before(:each) do
    @item = Object.new
    @item.stubs(:id => 1, :price => 20.5, :unitary_cost => 15.45,
                :discount => "10:3 15:4.5 20:5")
  end

  it 'should create a price with an Item' do
    Price.create_from_item(@item)
  end
end
