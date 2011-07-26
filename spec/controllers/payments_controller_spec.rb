require 'spec_helper'

describe PaymentsController do

  def mock_payment(stubs={})
    @mock_payment ||= Payment.tap do |payment|
      payment.stubs(stubs) unless stubs.empty?
    end
  end


  def mock_transaction(stubs = {})
    @mock_transaction ||= Transaction.tap do |transaction|
      transaction.stubs(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all payments as @payments" do
      log.info "stub auth"
      stub_auth
      Payment.stubs(:org => stub(:all => [mock_payment]) )

      get :index
      #puts assigns.keys
      assigns(:payments).should eq([mock_payment])
    end
  end

  describe "GET new" do
    it "assigns a new payment as @payment" do
      stub_auth
      mock_trans = mock_transaction(:new_payment => mock_payment)
      Transaction.stubs(:org => stub(:find => mock_trans) )

      get :new, :id => 1
      assigns(:transaction).should == mock_transaction
      assigns(:payment).should == mock_payment
    end
  end

  #describe "GET show" do
  #  it "assigns the requested payment as @payment" do
  #    Payment.stub(:find).with("37") { mock_payment }
  #    get :show, :id => "37"
  #    assigns(:payment).should be(mock_payment)
  #  end
  #end
  

  describe "POST create" do
    describe "with valid params" do
      before do
        stub_auth
      end 

      it 'when assigned account_id 1 it should correctly assing' do
        Transaction.stubs(:org => stub(:find => Transaction.new))
        Transaction.any_instance.stubs(:save_payment => true, :type => "Income")
        Account.stubs(:org => stub(:find_by_original_type => stub(:id => 100)) )
        post :create, :payment => {:account_id => '1'}, :id => 1, :format => 'js'

        assigns(:transaction).class.should_not == blank?
        controller.params[:payment][:account_id].should == "1"
        controller.params[:payment][:currency_id].should == nil
      end

      it 'when assigned account_id 1-2 it should correctly assing' do
        Transaction.stubs(:org => stub(:find => Transaction.new))
        Transaction.any_instance.stubs(:save_payment => true, :type => "Income")
        Account.stubs(:org => stub(:find_by_original_type => stub(:id => 100)) )
        post :create, :payment => {:account_id => '1-2'}, :id => 1, :format => 'js'

        assigns(:transaction).class.should_not == blank?
        controller.params[:payment][:currency_id].should == "2"
        controller.params[:payment][:account_id].should == "1"
      end

      it "when stubed method for action_id 1-2" do
        mock_trans = mock_transaction(:new_payment => mock_payment, :save_payment => true, :is_contact? => true)
        Transaction.stubs(:org => stub(:find => mock_trans) )

        post :create, :payment => {:account_id => '1-2' }, :id => 1, :format => 'js'
        assigns(:payment).should == mock_payment
        assigns[:transaction].is_contact?.should == true
        expect{ assigns[:transaction].is_account? }.to raise_error(NoMethodError)
      end


    end

    #describe "with invalid params" do
    #  it "assigns a newly created but unsaved payment as @payment" do
    #    Payment.stub(:new).with({'these' => 'params'}) { mock_payment(:save => false) }
    #    post :create, :payment => {'these' => 'params'}
    #    assigns(:payment).should be(mock_payment)
    #  end

    #  it "re-renders the 'new' template" do
    #    Payment.stub(:new) { mock_payment(:save => false) }
    #    post :create, :payment => {}
    #    response.should render_template("new")
    #  end
    #end

  end

end
