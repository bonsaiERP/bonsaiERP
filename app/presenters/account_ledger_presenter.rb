# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < BasePresenter
  attr_accessor :current_account_id

  def initials(name)
    name.split(' ').map(&:first).join('')
  end

  def status_text
    case status
    when 'pendent' then 'Pendiente'
    when 'approved' then 'Aprobado'
    when 'nulled' then 'Anulado'
    end
  end

  def status_tag
    case status
    when 'pendent'
      html = ["<span class='label label-warning'>", icon('icon-warning-sign'),
              " Pendiente</span>"].join('')
    when 'approved'
      html = "<span class='label label-success' title='Aprobado'>A</span>"
    when 'nulled'
      html = "<span class='label label-important' title='Anulado'>A</span>"
    end

    html.html_safe
  end

  def operation_label
    html = case to_model.operation
           when 'payin', 'intin'
             "<span class='label-success' >#{operation}</span>"
           when 'payout', 'devin'
             "<span class='label' >#{operation}</span>"
           when 'trans'
             "<span class='label' >#{operation}</span>"
           end

    html.html_safe
  end

  # Presents the amount referencing an account
  def amount_ref(ac_id = nil)
    case to_model.operation
    when 'payin', 'payout', 'devin', 'devout'
      amount
    when 'trans'
      if inverse?
        ac_id == account_id ? -amount_currency : amount
      else
        ac_id == account_id ? -amount_currency : amount
      end
    end
  end

  def currency_ref(ac_id = nil)
    ac_id == to_model.account_to_id ? currency : account_currency
  end

  def account_contact_tag
    html = ""
    if account_contact
      html << "<i class='icon-user'></i> #{ sanitize account_contact.to_s}"
    end

    html.html_safe
  end

  def operation_text
    case operation
    when 'payin'  then 'Cobro ingreso'
    when 'intin'  then 'Cobro Intereses'
    when 'payout' then 'Pago egreso'
    when 'intout' then 'Pago Intereses'
    when 'devin'  then 'Devolución ingreso'
    when 'devout' then 'Devolución egreso'
    when 'trans'  then 'Transferencia'
    end
  end

  def account_text
    case operation
    when 'payin', 'devin'  then 'Ingreso'
    when 'payout', 'devout' then 'Egreso'
    when 'trans'  then 'Cuenta'
    end
  end

  def operation_tag
    case operation
    when 'payin', 'intin'
      text_green operation_text
    when 'payout', 'intout', 'devin', 'devout'
      text_red operation_text
    when 'trans'
      text_dark operation_text
    end
  end

  def operation_tag
    case operation
    when 'payin', 'devout'
      text_green_dark(operation_text)
    when 'payout', 'devin'
      text_red(operation_text)
    when 'trans'
      text_dark(operation_text)
    end
  end

  def account_icon(ac)
    case ac.class.to_s
    when 'Cash'    then icon("icon-money")
    when 'Bank'    then icon("icon-building")
    when 'Income'  then icon("icon-file")
    when 'Expense' then icon("icon-file")
    end
  end

  def trans_amount
    if is_account?
      to_model.amount
    else
      -to_model.amount
    end
  end

  def trans_currency
    if is_account?
      account_currency
    else
      currency
    end
  end

  def is_account?
    @is_account ||= (account.is_a?(Income) || account_to.is_a?(Income))
  end

  def trans_operation_tag
    if is_account?
      operation_tag
    else
      op = case to_model.operation
      when 'payin' then 'payout'
      when 'payout' then 'payin'
      end
      operation_tag(op)
    end
  end

  def trans_currency?
    is_account? ? same_currency? : true
  end

  def trans_account
    if current_account_id == account_id
      account_to
    else
      account
    end
  end

  def trans_account_tag
    "#{account_icon trans_account} #{sanitize trans_account}".html_safe
  end

  def trans_account_icon
    account_icon trans_account
  end
end
