require 'spec_helper'

describe StaffsController do

  describe "POST create" do
    before(:all) do
      Staff.any_instance.stubs(:id => 1, :account => stub(:id => 2), :save => true, :presisted? => true )
    end

    it 'should save' do
      stub_auth
      post :create, :staff => {:first_name => "name"}
      assigns(:staff).id.should == 1
      response.should redirect_to(staff_url(1))
    end

    it 'should not be redirect when AJAX' do
      stub_auth
      request.stubs(:xhr? => true)
      cli = Staff.new() {|c| c.id = 1}

      cli.stubs(:save => true, :account => stub(:attributes => {:id => 2}) )
      Staff.stubs(:new => cli )

      xhr :post, :create, :staff => {:first_name => "name"}

      request.xhr?.should == true
      assigns(:staff).id.should == 1
      response.body.should =~ /{"id":1/
    end

    it 'should render action new when not saved correctly' do
      stub_auth
      Staff.any_instance.stubs(:save => false)
      post :create, :staff => {}
      response.should render_template('new')
    end
  end
end

