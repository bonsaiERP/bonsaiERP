require 'spec_helper'

describe PaymentsController do
  before do
    controller.stub!(check_authorization!: true, set_tenant: true, currency_id: 1)
  end

  context "POST /payments/:id/income" do
    it "checks all stub methods" do
      raise "IncomePayment#pay method doesn't exists" unless IncomePayment.method_defined?(:pay)
      raise "IncomePayment#income method doesn't exists" unless IncomePayment.method_defined?(:income)
    end

    it "creates an IncomePayment and redirects to Income" do
      Income.stub(exists?: true) # for before_filter
      IncomePayment.any_instance.stub(income: build(:income, id: 2), pay: true)

      post :income, id: 1, income_payment: {account_id: 2}

      flash[:notice].should be_present
      flash[:error].should_not be_present
      response.should redirect_to(income_path(2, anchor: 'payments'))
    end

    it "redirects to Income and sets the flash error message" do
      Income.stub(exists?: true) # for before_filter
      IncomePayment.any_instance.stub(income: build(:income, id: 2), pay: false)
      
      post :income, id: 1, income_payment: {account_id: 2}

      flash[:error].should be_present
      flash[:notice].should_not be_present
      response.should redirect_to(income_path(2, anchor: 'payments'))
    end

    it "redirects to dashboard when Income does not exists" do
      request.env['HTTP_REFERER'] = '/back'
      post :income, id: 1, income_payment: {account_id: 2}

      flash[:error].should eq('No se puede realizar el cobro, el ingreso no existe.')
      response.should redirect_to '/back'
    end
  end


  context "POST /payments/:id/expense" do
    it "checks all stub methods" do
      raise "ExpensePayment#pay method doesn't exists" unless ExpensePayment.method_defined?(:pay)
      raise "ExpensePayment#expense method doesn't exists" unless ExpensePayment.method_defined?(:expense)
    end

    it "creates an ExpensePayment and redirects to Expense" do
      Expense.stub(exists?: true) # for before_filter
      ExpensePayment.any_instance.stub(expense: build(:expense, id: 2), pay: true)

      post :expense, id: 1, expense_payment: {account_id: 2}

      flash[:notice].should be_present
      flash[:error].should_not be_present
      response.should redirect_to(expense_path(2, anchor: 'payments'))
    end

    it "redirects to Expense and sets the flash error message" do
      Expense.stub(exists?: true) # for before_filter
      ExpensePayment.any_instance.stub(expense: build(:expense, id: 2), pay: false)
      

      post :expense, id: 1, expense_payment: {account_id: 2}

      flash[:error].should be_present
      flash[:notice].should_not be_present
      response.should redirect_to(expense_path(2, anchor: 'payments'))
    end

    it "redirects to dashboard when Expense does not exists" do
      request.env['HTTP_REFERER'] = '/back'

      post :expense, id: 1, expense_payment: {account_id: 2}

      flash[:error].should eq('No se puede realizar el pago, el egreso no existe.')
      response.should redirect_to '/back'
    end
  end
end
