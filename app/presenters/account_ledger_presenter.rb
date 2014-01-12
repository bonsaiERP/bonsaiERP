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

  def amount_currency
    case
    when(current_account_id == account.id && account.is_a?(Income))
      to_model.amount_currency
    when(current_account_id == account_to.id && account_to.is_a?(Expense))
      - to_model.amount_currency
    else
      to_model.amount_currency
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
    @ledger_operation_presenter ||= LedgerOperationsPresenter.new(self)
  end
end

class LedgerOperationsPresenter < Struct.new(:presenter)
  delegate :operation, :account, :account_id,
           :account_to, :account_to_id,
           :current_account, :current_account_id,
           :other_account, :id, to: :presenter

  delegate :text_green, :text_green_dark, :text_red, :text_dark, to: :template

  OPERATIONS = ['trans',  # trans  = Transfer from one account to other
                'payin',  # payin  = Payment in Income, adds ++
                'payout', # payout = Paymen out Expense, substracts --
                'devin',  # devin  = Devolution in Income, adds --
                'devout', # devout = Devolution out Expense, substracts ++
                'lrcre',  # lrcre  = Create the ledger Loans::Receive, adds ++
                'lrpay',  # lrpay  = Loans::Receive make a payment, substracts --
                'lrint',  # lrint  = Interest Loans::Receive --
                #'lrdev',  # lrdev  = Loans::Receive make a devolution, adds ++
                'lgcre',  # lgcre  = Create the ledger Loans::Give, substract --
                'lgint',  # lgint  = Interests for Loans::Give ++
                'lgpay',  # lgpay  = Loans::Give receive a payment, adds ++
                #'lgdev',  # lgdev  = Loans::Give make a devolution, substract --
                'servex', # servex = Pays an account with a service account_to is Expense
                'servin', # servin = Pays an account with a service account_to is Income
               ].freeze

  def operation_tag
    #binding.pry if id == 280
    case
    when %w(payin devout).include?(operation)
      text_green_dark(operation_text)
    when %w(payout devin).include?(operation)
      text_red(operation_text)
    when 'trans' == operation
      text_dark(operation_text)
    when( 'servex' == operation && current_account_id == account.id)
      text_green 'Cobro contra servicio'
    when( 'servex' == operation && current_account_id != account.id)
      text_red 'Pago contra servicio'
    when (is_income? && 'lrpay' == operation)
      text_green 'Contra prestamo'
    when (other_is_income? && 'lrpay' == operation)
      text_green 'Contra ingreso'
    when 'lrcre' == operation
      text_green_dark 'Ingreso prestamo'
    when 'lrpay' == operation
      text_red 'Pago prestamo'
    when 'lrint' == operation
      text_red 'Pago intereses'
    when 'lgcre' == operation
      text_red 'Egreso prestamo'
    when 'lgpay' == operation
      text_green_dark 'Cobro prestamo'
    when 'lgint' == operation
      text_green_dark 'Cobro intereses'
    end
  end

  def operation_text
    case operation
      when 'trans' then 'Transferencia'  # trans  = Transfer from one account to other
      when 'payin' then 'Cobro ingreso'  # payin  = Payment in Income, adds ++
      when 'payout' then 'Pago egreso' # payout = Paymen out Expense, substracts --
      when 'devin' then 'Devolución ingreso'  # devin  = Devolution in Income, adds --
      when 'devout' then 'Devolución egreso' # devout = Devolution out Expense, substracts ++
      when 'lrcre' then 'Ingreso prestamo'  # lrcre  = Create the ledger Loans::Receive, adds ++
      when 'lrpay' then 'Pago perstamo'  # lrpay  = Loans::Receive make a payment, substracts --
      when 'lrint' then 'Pago intereses'  # lrint  = Interest Loans::Receive --
      #'lrdev',  # lrdev  = Loans::Receive make a devolution, adds ++
      when 'lgcre' then 'Egreso prestamo'  # lgcre  = Create the ledger Loans::Give, substract --
      when 'lgint' then 'Cobro intereses' # lgint  = Interests for Loans::Give ++
      when 'lgpay' then 'Cobro prestamo'  # lgpay  = Loans::Give receive a payment, adds ++
      #'lgdev',  # lgdev  = Loans::Give make a devolution, substract --
      when 'servex' then 'Pago con egreso' # servex = Pays an account with a service account_to is Expense
      when 'servin' then 'Cobro con ingreso' # servin = Pays an account with a service account_to is Income
    end
  end

  def is_income?
    current_account.is_a?(Income)
  end

  def other_is_income?
    other_account.is_a?(Income)
  end

  def is_expense?
    current_account.is_a?(Expense)
  end

  def other_is_expense?
    other_account.is_a?(Expense)
  end

  def is_loan?
    current_account.is_a?(Loan)
  end

  def template
    presenter.template
  end
end
