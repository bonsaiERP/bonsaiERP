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
        #Transaction.stubs(:org => stub(:find => mock_payment(:new_payment => AccountLedger.new, :save_payment => true, :draft? => false ) ) )
        Transaction.stubs(:org => stub(:find => Income.new))
        Income.any_instance.stubs(:valid? => true, :save_payment => true, :draft? => false)
        #Account.stubs(:org => stub(:find_by_original_type => stub(:id => 1)))
      end 

      it 'when assigned should render create with account_id = 1' do

        xhr :post, :create, :account_ledger => {:transaction_id => 1, :account_id => "1", :reference => "Test"}
        response.should render_template('create')

        controller.params[:account_ledger][:account_id].should == "1"
        controller.params[:account_ledger][:currency_id].should == nil
      end

      it 'when assigned should render create with account_id = 1' do

        xhr :post, :create, :account_ledger => {:transaction_id => 1, :account_id => "1-2", :exchange_rate => "0.5", :reference => "Test"}
        response.should render_template('create')

        assigns(:account_ledger).account_id.should == 1
        assigns(:account_ledger).currency_id.should == 2
      end
    end

    describe "with invalid params" do
      before do
        stub_auth
        Transaction.stubs(:org => stub(:find => mock_payment(:new_payment => AccountLedger.new, :save_payment => false ) ) )
      end

      it 'when wrong params should render new template' do
        xhr :post, :create, :account_ledger => {:transaction_id => 1, :account_id => "1"}
        response.should render_template('new')
      end
    end

  end

end
