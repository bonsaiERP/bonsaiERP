require 'spec_helper'

describe Store do
  it { should have_many(:stocks) }
  it { should have_many(:inventories) }

  it { should validate_presence_of(:name) }
  it { should have_valid(:name).when('123', 'Store') }
  it { should_not have_valid(:name).when('12', 'St',  '') }
  it { should have_valid(:address).when('12345', 'Samaipata', '') }
  it { should_not have_valid(:address).when('1234', 'St') }
  it { should validate_uniqueness_of(:name) }

  let(:valid_attributes) {
    {name: 'Store Samaipata 1', address: 'Samaipata', phone: '706-81101'}
  }


  it "#destroy" do
    st = Store.create!(valid_attributes)

    st.stub(stocks: [1])
    st.destroy.should eq(false)
    st.errors[:base].should eq([I18n.t('errors.messages.store.destroy')])

    st.errors.clear
    st.stub(stocks: [])
    st.should respond_to(:inventories)
    st.stub(inventories: [1])
    st.destroy.should eq(false)
    st.errors[:base].should eq([I18n.t('errors.messages.store.destroy')])

    st.errors.clear
    st.stub(stocks: [])
    st.stub(inventories: [])
    st.destroy.destroyed?.should eq(true)
  end

  #def create_items(number = 10)
    #(1..10).each do |num|
      #i = Item.create(:name => "item #{num}", :unit_id => 1,
                  #:code => "P-00#{num}", :ctype => 'product') {|i| i.organisation_id = 1}
    #end
  #end

  ## name
  #it {should have_valid(:name).when("Uno")}
  #it {should_not have_valid(:name).when("Un")}
  ## address
  #it {should have_valid(:address).when("Somewhere")}
  #it {should_not have_valid(:address).when("1234")}

  #it 'should create' do
    #Store.create!(valid_params)
  #end


  #it 'should return a list of items even if there is not in the stock' do
    #create_items(10)
    #Unit.create(:name => 'Unit', :abbreviation => 'Unt.') {|u| u.id = 1 }
    #Item.org.count.should == 10

    #s = Store.create!(valid_params)
    #s.should be_persisted

    #ids = Item.org.map(&:id)[0...5]
    #h = s.hash_of_items(ids)

    #h.keys.should have(5).elements
    #h[ids.first][:quantity].should == 0
    #h[ids.first][:minimum].should == ""
  #end
end
