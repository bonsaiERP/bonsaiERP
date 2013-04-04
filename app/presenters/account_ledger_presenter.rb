# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < Resubject::Presenter
  include UsersModulePresenter

  def initials(name)
    name.split(' ').map(&:first).join('')
  end

  def verified_tag
    html = if can_conciliate_or_null?
             "<i class='icon-remove text-error' title='No verficado' rel='tooltip'></i>"
           else
            "<i class='icon-ok text-success' title='Verficado' rel='tooltip'></i>"
           end

    html.html_safe
  end

  def nulled_tag
    unless active?
      "<span class='label label-important'>ANULADA</span>".html_safe
    end
  end

  def operation_label
    html = case to_model.operation
           when 'payin', 'intin'
             "<span class='label label-success' >#{operation}</span>"
           when 'payout', 'devin'
             "<span class='label label-important' >#{operation}</span>"
           when 'trans'
             "<span class='label label-inverse' >#{operation}</span>"
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
      html << "<i class='icon-user'></i> #{account_contact}"
    end

    html.html_safe
  end

  def operation(op = to_model.operation)
    case op
    when 'payin'
      'Cobro'
    when 'intin'
      'Cobro Int.'
    when 'payout'
      'Pago'
    when 'intout'
      'Pago Int.'
    when 'devin', 'devout'
      'Devolución'
    when 'trans'
      'Transferencia'
    end
  end

  def operation_tag(op = to_model.operation)
    text = operation(op)
    css = case op
          when 'payin', 'intin', 'devout'
            'label-success'
          when 'payout', 'intout', 'devin'
            'label-important'
          when 'trans'
            'label-inverse'
          end

    "<span class='label #{css}'>#{text}</span>".html_safe
  end

  def account_icon(ac)
    case ac.class.to_s
    when 'Cash' then '<i class="icon-money dark" title="Efectivo" rel="tooltip"></i>'
    when 'Bank' then '<i class="icon-building dark" title="Banco" rel="tooltip"></i>'
    when 'Income' then '<i class="icon-file dark" title="Ingreso" rel="tooltip"></i>'
    when 'Expense' then '<i class="icon-file dark" title="Egreso" rel="tooltip"></i>'
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
    if is_account?
      account_to
    else
      account
    end
  end

  def trans_account_tag
    "#{account_icon trans_account} #{trans_account}".html_safe
  end
end
