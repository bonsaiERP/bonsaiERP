class IncomePresenter < Resubject::Presenter
  currency :balance, precision: 2

  def income_payment
    IncomePayment.new(account_id: id, date: Date.today, amount: 0)
  end

  def payments
    present to_model.payments, AccountLedgerPresenter
  end

  def balance?
    to_model.balance > 0
  end
end
