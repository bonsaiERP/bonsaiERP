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

  def payment_date_tag
    d = ""
    unless is_paid?
      d = "<span class='muted'>Vence el</span> "
      d << l(to_model.payment_date)
      d << "<span class='text-error' title='Fecha de cobro atrasada' rel='tooltip'>#{d}<span>" if today > to_model.payment_date
    end
    d.html_safe
  end

  include UsersModulePresenter

private
  def today
    @today ||= Date.today
  end
end
