require 'spec_helper'

describe PaymentsController do
  before do
    controller.stub!(check_authorization!: true, set_tenant: true, currency_id: 1)
  end

  context "POST /payments" do
    let(:income) { build :income, id: 1 }
    it "initializes according to the class passed with params[:klass]" do
      PaymentIncome.any_instance.stub(pay: true, transaction: income)

      post :create, klass: 'PaymentIncome', payment_income: {date: Date.today.to_s, transaction_id: 1}

      assigns(:payment).should be_a(PaymentIncome)

      response.should redirect_to('/incomes/1')
    end

    it "redirects to incomes_path" do
      post :create, klass: 'Je'

      response.should redirect_to '/incomes'
    end
  end
end
