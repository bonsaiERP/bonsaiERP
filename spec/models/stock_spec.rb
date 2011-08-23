require 'spec_helper'

describe Stock do
  before do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
  end

  it { should have_valid(:minimum).when(1)}
  it { should have_valid(:minimum).when("")}
  it { should_not have_valid(:minimum).when(0)}

  it 'should create a new active stock' do
    s = Stock.new
    s.should be_active
  end

  describe "Update minimum" do

    it 'should create an instance' do
      Stock.stubs(:org => stub(:find_by_store_id_and_item_id => Stock.new(:minimum => 12, :quantity => 20, :item_id => 10))
                 )

      s = Stock.new_item(:item_id => 10, :store_id => 1)
      s.item_id.should == 10
      s.quantity.should == 20
      s.minimum.should == 12
    end

    it 'should return false if there is no stock' do
      Stock.stubs(:org => stub(:find_by_store_id_and_item_id => nil)
                 )

      s = Stock.new_item(:item_id => 10, :store_id => 1)
      s.should be_false
    end

    it 'should assing the new minimum' do
      Stock.stubs(:org => stub(:find_by_store_id_and_item_id => Stock.new(:minimum => 12, :quantity => 20, :item_id => 10))
                 )
      
      s = Stock.new_item(:item_id => 10, :store_id => 1, :minimum => 22)
      s.minimum.should == 22
      s.quantity.should == 20
    end


  end
end
