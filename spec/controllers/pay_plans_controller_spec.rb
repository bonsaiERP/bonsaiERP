require 'spec_helper'

describe PayPlansController do

  describe "DELETE pay_plans" do
    it 'should destroy pay_plans' do
      stub_auth
      Transaction.stubs(:org => stub(:find => Transaction.new() {|t| t.id = 1}) )

      Transaction.any_instance.stubs(:destroy_pay_plans => true)

      delete :destroy, :id => "1", :ids => ["1", "2"]

      assigns(:transaction).class.to_s.should == "Transaction"

    end
  end
end
