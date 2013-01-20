class IncomePresenter < Resubject::Presenter
  currency :balance, precision: 2

  def payment_income
    PaymentIncome.new(account_id: account_id,)
  end
end
