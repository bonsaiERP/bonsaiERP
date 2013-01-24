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

  def has_error_label
    "<span class='label label-important' rel='tooltip' title='Corrija los errores'>ERROR</span>".html_safe if to_model.has_error?
  end

  def payment_date_tag
    d = ""
    unless is_paid?
      css = ( today > to_model.payment_date ) ? "text-error" : ""
      d = "<span class='muted'>Vence el:</span>"
      d << "<span class='i #{css}'><i class='icon-time'></i> "
      d << l(to_model.payment_date)
      d << "</span>"
    end
    d.html_safe
  end

  include UsersModulePresenter

private
  def today
    @today ||= Date.today
  end
end
