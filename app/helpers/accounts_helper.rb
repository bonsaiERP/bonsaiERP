# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module AccountsHelper
  def with_payment(al)
    if al.payment
      txt = ntc(al.payment_amount) + ' + ' + ntc(al.payment_interests_penalties)

      link_to(txt, "/payments/#{al.payment_id}/transaction", :title => 'Cantidad + intereses/penalidades')
    end
  end

  # Creates a link to the transaction if exists
  def link_description(al)
    if al.transaction_id.present?
      link_to al.description, al.transaction
    elsif al.account_ledger_id.present?
      link_to al.description, "/account_ledgers/#{al.account_ledger_id}"
    else
      al.description
    end
  end

  # links to the correct account for account_ledger
  def link_account(al)
    case al.account_type
    when"Bank" then link_to "Cuentas bancarias", al.account
    when"CashRegister" then link_to "Cuentas caja", al.account
    end
  end

  # Links to the parent
  def link_list(klass)
    case klass.account.accountable.class.to_s
    when "Bank" then link_to "Bancos", banks_path
    when "Cash" then link_to "Cajas", cashes_path
    end
  end

  def link_parent(klass)
    link_to klass.account, klass.account.accountable
  end

  # Creates for income or outcome title
  def account_ledger_title(klass)
    if klass.in?
      "<span class='dark_green'>ingreso</span>".html_safe
    else
      "<span class='red'>egreso</span>".html_safe
    end
  end


  def account_ledger_contact_label(klass)
    if klass.income?
      "Cliente"
    else
      "Proveedor"
    end
  end


  def account_ledger_contact_collection(klass)
    if klass.income?
      Client.org
    else
      Supplier.org
    end
  end

  def pluralize_conciliation(klass)
    if klass.account_ledgers.pendent.size == 1
      "1 renvisión pendiente"
    else
      "#{klass.account_ledgers.pendent.size} revisiones pendientes"
    end
  end

  def link_pendent_ledgers(klass)
    link_to( "Revisiones pendientes (#{klass.account_ledgers.pendent.size})", "#{polymorphic_url(klass)}?option=false") if klass.account_ledgers.pendent.any?
  end

  # Confirmation for acccount_ledger destroy
  def account_ledger_destroy_confirm_dialog(klass)
    if klass.account_ledger_id.present?
      "Anular esta transacción tambien anulara la transacción relacionada con la transferencia, eta seguro de anularla?"
    else
      "Esta seguro de anular la transacción?"
    end
  end

  # Conciliation
  def conciliate_css(klass)
    klass.conciliation == false ? "sync" : ""
  end
end
