class Loans::GivePresenter < BasePresenter
  def loan_type_tag
    "#{icon 'icon-logout fs130 green'} Prestamo otorgado".html_safe
  end

  def due_date_tag
    txt =  due_date < today ? text_red(template.l due_date) : template.l(due_date)

    "<span class='muted'>Vence el</span> #{txt}".html_safe  unless is_paid?
  end

  def due_date_color
    if due_date < today
      text_red l(due_date)
    else
      l due_date
    end
  end

  def new_ledger_in
    @_new_ledger_in ||= LoanLedgerInForm.new(loan_id: to_model.id)
  end

  def payment_path
    template.new_charge_loan_payment_path(id)
  end

  def state_tag
    if 'paid' == state
      text_green 'Cobrado'
    else
      text_red 'Pendiente'
    end
  end

  def ledger_ins_title
    I18n.t('presenters.loans.give.ledger_ins_title')
  end

  def payments
    to_model.payments
    .includes(:account, :account_to)
    .includes(*user_log_list)
  end

  def interest_ledgers
    to_model.interest_ledgers
    .includes(:account, :account_to)
    .includes(*user_log_list)
  end

  def payments_title
    'Cobros'
  end

  def interest_path
    template.new_charge_interest_loan_payment_path(id)
  end

  def payment_link
    link_to payment_path, class: 'btn btn-success', data: { target: '#payment-form' } do
      "#{icon('icon-plus-sign')} Cobrar prestamo".html_safe
    end
  end

  def interest_link
    link_to interest_path, class: 'btn btn-success', data: { target: '#interest-form' } do
      "#{icon('icon-plus-sign')} Cobrar intereses".html_safe
    end
  end

  def new_ledger_in_path
    context.new_give_loan_ledger_in_path(id)
  end

  def ledger_in_path
    context.give_loan_ledger_in_path(id)
  end

  def ledger_ins
    to_model.ledger_ins.includes(:account, :account_to, :updater, :creator, :approver, :nuller)
  end

end
