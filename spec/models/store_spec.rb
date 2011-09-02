require 'spec_helper'

describe Store do
  let(:valid_params) {
    {:name => 'Store 1', :address => 'Los Pinos Bloque 80 dpto. 201'}
  }
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
  end

  def create_items(number = 10)
    (1..10).each do |num|
      i = Item.create(:name => "item #{num}", :unit_id => 1,
                  :code => "P-00#{num}", :ctype => 'product') {|i| i.organisation_id = 1}
    end
  end

  # name
  it {should have_valid(:name).when("Uno")}
  it {should_not have_valid(:name).when("Un")}
  # address
  it {should have_valid(:address).when("Somewhere")}
  it {should_not have_valid(:address).when("1234")}

  it 'should create' do
    Store.create!(valid_params)
  end


  it 'should return a list of items even if there is not in the stock' do
    create_items(10)
    Unit.create(:name => 'Unit', :abbreviation => 'Unt.') {|u| u.id = 1 }
    Item.org.count.should == 10

    s = Store.create!(valid_params)
    s.should be_persisted


    h = s.get_hash_of_items(:item_id => Item.org.map(&:id)[0...5])
    h.keys.should have(5).elements
  end
end
