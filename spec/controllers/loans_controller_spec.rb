# encoding: utf-8
require 'spec_helper'

describe LoansController do
  before(:each) do
    stub_auth
    OrganisationSession.set currency_id: 2
  end

  describe "new" do
    it 'should create a new Loanin' do
      get :new, operation: "in"

      assigns(:loan).is_a?(Loanin).should be_true
      response.should render_template("new")
      response.should_not be_redirect
    end

    it 'should create a new Loanout' do
      get :new, operation: "out"

      assigns(:loan).is_a?(Loanout).should be_true
      response.should render_template("new")
      response.should_not be_redirect
    end

    it 'should redirect to loans_path' do
      get :new
      
      response.should redirect_to(loans_path)
      flash[:error].should_not be_blank
    end

  end

  describe "create"do
    describe "save:true" do
      before(:each) do
        Loanin.any_instance.stub(save: true, id: 1)
      end

      it 'should create a new loan' do
        post :create, loanin: {operation: "in", currency_id: 1}

        assigns(:loan).is_a?(Loanin).should be_true
      end

      it 'should redirect to the show view' do
        post :create, loanin: {operation: "in"}

        response.should redirect_to(loan_path(1))
        flash[:notice].should_not be_blank
      end
    end

    describe "save:false" do
      before(:each) do
        Loanin.any_instance.stub(save: false)
      end

      it 'should render new action' do
        post :create, loanin: {operation: "in", currency_id: 1}
        
        response.should_not be_redirect
        response.should render_template("new")
      end

      it 'should assing the correct loan' do
        Loanout.any_instance.stub(save: true, id: 1)
        post :create, loanout: {operation: "out", account_id: 1}
        
        assigns(:loan).is_a?(Loanout).should be_true
      end
    end

  end

  describe "edit" do
  
    it 'should redirect if the loan is not draft' do
      loan = Loanin.new {|v| 
        v.id = 10
        v.state = "approved"
      }
      Loan.stub!(get_loan: loan)

      get :edit, id: 10

      response.should redirect_to(loan_path(10))
    end

    it 'should redirect if is not loan' do
      Loan.stub!(get_loan: Transaction.new)

      get :edit, id: 10

      response.should redirect_to(loans_path)
    end

    it 'should render' do
      loan = Loanin.new {|v| 
        v.id = 10
        v.state = "draft"
      }
      Loan.stub!(get_loan: loan)

      get :edit, id: 10

      response.should render_template('edit')
    end
  end

  describe "update" do
    it 'should redirect if is not a loan' do
      Loan.get_loan(get_loan: Transaction.new)

      put :update, id:1, loanin: {}

      response.should redirect_to(loans_path)
      flash[:warning].should_not be_blank
    end

    it 'should redirect if is not draft' do
      Loan.stub!(get_loan: mock_model(is_loan?: true, draft: false, id: 10))

      put :update, id: 10, loanin: {}

      response.should redirect_to(loans_pat(10))
      flash[:warning].should_not be_blank
    end
  end
end
