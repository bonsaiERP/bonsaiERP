require 'spec_helper'

describe StoresController do
  describe "DELETE" do
    before(:each) do
      controller.stubs(:check_authorization! => true)
    end

    it 'should not delete' do
      s = Store.new {|s| s.id = 1}
      s.stubs(:destroy => false, :destroyed? => false, :persisted? => true)
      Store.stubs(:org => stub(:find => s))

      delete :destroy, :id => 1

      response.should redirect_to(store_path(1))
      flash[:notice].should be_blank
      flash[:warning].should_not be_blank
    end

    it 'should delete and redirect' do
      s = Store.new {|s| s.id = 1}
      s.stubs(:destroy => true, :destroyed? => true)
      Store.stubs(:org => stub(:find => s)) 

      delete :destroy, :id => 1

      response.should redirect_to(stores_path)
      flash[:notice].should_not be_blank
      flash[:warning].should be_blank
    end
  end

end
