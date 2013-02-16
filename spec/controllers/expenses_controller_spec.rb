require 'spec_helper'

describe ExpensesController do
  before(:each) do
    stub_auth
    controller.stub(currency: 'BOB')
  end

  describe "POST /expenses" do
    let(:expense) do
      inc = build(:expense, id: 1)
      inc.stub(persisted?: true)
      inc
    end

    before(:each) do
      DefaultExpense.any_instance.stub(expense: expense)
    end

    it "creates_and_approves" do
      raise "Invalid DefaultExpense#create method doesn't exist" unless DefaultExpense.method_defined?(:create_and_approve)
      DefaultExpense.any_instance.should_receive(:create).and_return(true)

      post :create, expense: {currency: 'BOB'}, commit_approve: 'Com Save'

      response.should redirect_to(expense_path(1))
    end
  end

  describe "PUT /expenses/:id" do
    let(:expense) do
      inc = build(:expense, id: 1)
      inc.stub(persisted?: true)
      inc
    end

    it "updates" do
      Expense.stub(find: expense)
      DefaultExpense.any_instance.should_receive(:update).and_return(true)

      put :update,  id: 1, expense: {currency: 'BOB'}

      response.should redirect_to(expense_path(1))
      flash[:notice].should eq('El egreso fue actualizado!.')
    end

    it "updates_and_approves" do
      Expense.stub(find: expense)
      DefaultExpense.any_instance.should_receive(:update_and_approve).and_return(true)

      put :update,  id: 1, commit_approve: 'Save', expense: {currency: 'BOB'}

      response.should redirect_to(expense_path(1))
      flash[:notice].should eq('El egreso fue actualizado!.')
    end
  end


end
