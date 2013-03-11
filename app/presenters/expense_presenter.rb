# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensePresenter < Resubject::Presenter
  currency :balance, precision: 2

  def expense_payment
    ExpensePayment.new(account_id: id, date: Date.today, amount: 0)
  end

  def expense_devolution
    ExpenseDevolution.new(account_id: id, date: Date.today, amount: 0)
  end

  def payments
    present to_model.payments, AccountLedgerPresenter
  end

  def payments_rel
    present AccountLedger.where("account_id=:id OR account_to_id=:id", id: id).order('date desc, id desc'), AccountLedgerPresenter
  end

  def interests
    present to_model.interests, AccountLedgerPresenter
  end

  def balance?
    to_model.balance > 0
  end

  def has_error_label
    "<span class='label label-important' rel='tooltip' title='Corrija los errores'>ERROR</span>".html_safe if to_model.has_error?
  end

  def state_tag
    html = case state
    when "draft" then span_label('borrador')
    when "approved" then span_label('aprovado', 'label-info')
    when "paid" then span_label('pagado', 'label-success')
    end

    html.html_safe
  end

  def due_date_tag
    d = ""
    if is_approved?
      css = ( today > to_model.due_date ) ? "text-error" : ""
      d = "<span class='muted'>Vence el:</span> "
      d << "<span class='i #{css}'><i class='icon-time'></i> "
      d << l(to_model.due_date)
      d << "</span>"
    end
    d.html_safe
  end

  include UsersModulePresenter

  # To load methods related to the Transaction  model
  Transaction.transaction_columns.each do |m|
    define_method m do
      to_model.send(m)
    end
  end

private
  def today
    @today ||= Date.today
  end

  def span_label(txt, css="")
    "<span class='label #{css}'>#{txt}</span>"
  end
end

