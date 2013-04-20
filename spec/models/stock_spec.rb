require 'spec_helper'

describe Stock do
  before do
    #OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
  end

  #it { should have_valid(:minimum).when(1)}
  #it { should have_valid(:minimum).when("")}
  #it { should_not have_valid(:minimum).when(0)}

  #it 'should create a new active stock' do
    #s = Stock.new
    #s.should be_active
  #end

  #describe "When updating stock minimum" do
    #before do
      #OrganisationSession.set :id => 1
      #UserSession.current_user = User.new {|u| u.id = 2}
    #end

    #it 'should create an stock with minimum 0' do
      #s = Stock.new(:item_id => 1, :store_id => 1, :quantity => 10)
      #s.save.should be_true
      #s.minimum.should == 0
      #s.organisation_id.should == 1

      #s2 = Stock.create(:item_id => 1, :store_id => 1, :quantity => 20)
      #s2.should be_persisted
      #s2.quantity.should == 20
      #s2.minimum.should == 0
      #Stock.org.size.should == 1
      #Stock.unscoped.size.should == 2
    #end

    #it 'should recover the minimum from the last stock' do
      #s = Stock.create(:item_id => 1, :store_id => 1, :quantity => 20)
      #s.user_id.should be_blank
      #s = Stock.new_minimum(1, 1)
      #s.minimum.should == 0
      #s.should be_instance_of(Stock)
      
      ## Validation
      #s.save_minimum(-2).should be_false
      #s.errors[:minimum].should_not be_blank
      #s.errors[:minimum].should == [I18n.t("errors.messages.greater_than", :count => 0)]

      #s.save_minimum(20).should be_true
      #s.reload
      #s.minimum.should == 20
      #s.user_id.should_not be_blank
      #s.user_id.should == 2
      #s_id = s.id

      #s = Stock.create(:item_id => 1, :store_id => 1, :quantity => 0)
      #s.minimum.should == 20
      #s.id.should_not == s_id
    #end
  #end
end
