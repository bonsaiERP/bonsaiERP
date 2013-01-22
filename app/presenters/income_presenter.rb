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

  def payment_date
    d = ""
    unless is_paid?
      d = l to_model.payment_date
      d = "<span class='text-error' title='Fecha de cobro atrasada' rel='tooltip'>#{d}<span>" if today > to_model.payment_date
    end
    d
  end

  include UsersModulePresenter

private
  def today
    @today ||= Date.today
  end
end
