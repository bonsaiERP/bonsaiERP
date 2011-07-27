require 'spec_helper'

describe ClientsController do

  describe "POST create" do
    before(:all) do
      Client.any_instance.stubs(:id => 1, :account => stub(:id => 2), :save => true, :presisted? => true )
    end

    it 'should save' do
      stub_auth
      post :create, :client => {:first_name => "name"}
      assigns(:client).id.should == 1
      response.should redirect_to(client_url(1))
    end

    it 'should not be redirect when AJAX' do
      stub_auth
      request.stubs(:xhr? => true)
      cli = Client.new() {|c| c.id = 1}

      cli.stubs(:save => true, :account => stub(:attributes => {:id => 2}) )
      Client.stubs(:new => cli )

      xhr :post, :create, :client => {:first_name => "name"}

      request.xhr?.should == true
      assigns(:client).id.should == 1
      response.body.should =~ /{"id":1/
    end

    it 'should render action new when not saved correctly' do
      stub_auth
      Client.any_instance.stubs(:save => false)
      post :create, :client => {}
      response.should render_template('new')
    end
  end
end
