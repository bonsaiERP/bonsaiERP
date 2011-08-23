require 'spec_helper'

describe StocksController do
  before(:each) do
    stub_auth
    OrganisationSession.set :id => 1
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it 'should create an instance of an stock' do
      Stock.stubs(:new_item => Stock.new(:minimum => 12, :quantity => 20, :item_id => 10) )

      get 'new'
      assigns(:stock).class.should be(Stock)

      response.should render_template(:new)
    end

    it 'should render text' do
      s = Stock.stubs(:new_item => false )
      response.should_not render_template(:new)
    end
  end

  describe "POST 'create'" do
    before(:each) do
      st = Stock.new
      st.stubs(:save => true)
      s = Stock.stubs(:new_item => st )
    end

    it "should be successful" do
      post 'create', :stock => {:minimum => 10, :store_id => 1, :item_id => 10 }
      response.should be_true
    end

    it 'should assing the right template' do
      post 'create', :stock => {:minimum => 10, :store_id => 1, :item_id => 10 }
      response.should_not render_template(:new)
    end

  end

  describe "POST create with errors" do
    
    it 'should render new if it is wrong or inexsisten' do
      Stock.stubs(:new_item => false)

      post 'create', :stock => {:minimum => 10, :store_id => 1, :item_id => 10 }
      response.should render_template(:new)
    end

    it 'should render Error' do
      Stock.stubs(:new_item => Stock.new.stubs(:save => false))
      
      response.should render_template(:new)
    end
  end

end
