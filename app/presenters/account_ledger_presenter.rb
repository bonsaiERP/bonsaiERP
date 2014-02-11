# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < BasePresenter
  attr_accessor :current_account_id

  delegate :operation_tag, :operation_text, to: :ledger_operation_presenter

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

  def contact_link_tag(tag = :h5)
    if contact.present?
      template.content_tag tag, class: 'ib' do
        link_to contact, contact
      end
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
  def amount_ref
    case to_model.operation
    when 'payin', 'payout', 'devin', 'devout', 'lgcre', 'lrcre'
      amount
    when 'trans', 'servin', 'servex', 'lgpay', 'lgint', 'lrpay', 'lrint'
      related_amount
    end
  end

  def related_amount
    if current_account_id == account_id
      amount_currency
    else
      -amount_currency
    end
  end

  #def amount_currency
  #  case
  #  when(current_account_id == account.id && account.is_a?(Income))
  #    to_model.amount_currency
  #  when(current_account_id == account_to.id && account_to.is_a?(Expense))
  #    - to_model.amount_currency
  #  else
  #    to_model.amount_currency
  #  end
  #end

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

  def account_text
    case operation
    when 'payin', 'devin'  then 'Ingreso'
    when 'payout', 'devout' then 'Egreso'
    when 'trans'  then 'Cuenta'
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

  def current_currency?
    current_account.currency == currency
  end

  def current_account
    @current_account ||= current_account_id == account_id ? account : account_to
  end

  def other_account
    @other_account ||= current_account_id == account_id ? account_to : account
  end

  def other_account_url
    if other_account.is_a?(Loan)
      template.loan_path(other_account.id)
    else
      other_account
    end
  end

  def other_account_tag
    "#{account_icon other_account} #{sanitize other_account}".html_safe
  end

  def other_account_icon
    account_icon other_account
  end

  def model_url(mod)
    if mod.is_a?(Loan)
      template.loan_path(mod.id)
    else
      mod
    end
  end

  def account_to_url
    model_url(account_to)
  end

  def account_url
    model_url(account)
  end

  def ledger_operation_presenter
    @ledger_operation_presenter ||= LedgerOperationPresenter.new(to_model, current_account_id, context)
  end
end
