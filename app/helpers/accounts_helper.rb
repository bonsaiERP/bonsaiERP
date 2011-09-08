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
    unless al.description.blank?
      if al.transaction_id.present?
        link_to al.description, al.transaction
      else
        al.description
      end
    end
  end

  def link_contacts(account)
    case account.original_type
    when "Client"   then link_to "Clientes", clients_path
    when "Supplier" then link_to "Proveedores", suppliers_path
    when "Staff"    then link_to "Personal", staffs_path
    end
  end

  # links to the correct account for account_ledger
  def link_account(al)
    ac = al.ac_id == al.account_id ? :account : :to

    case al.send(ac).accountable.class.to_s
    when"Bank" then link_to "Cuentas bancarias", "/banks"
    when"Cash" then link_to "Cuentas caja", "/cashes"
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
    if klass.trans?
      "Anular esta transacción tambien anulara la transacción relacionada con la transferencia, eta seguro de anularla?"
    else
      "Esta seguro de anular la transacción?"
    end
  end

  # Conciliation
  def conciliate_css(klass)
    klass.can_conciliate? ? "sync" : ""
  end

  # Sets the link for the ledger
  def related_account_link(account_ledger)
    if account_ledger.transaction_id.present?
      case account_ledger.transaction_type
        when "Income" then income_path(account_ledger.transaction_id, :anchor => 'payments')
        when "Buy" then buy_path(account_ledger.transaction_id, :anchor => 'payments')
        when "Expense" then expense_path(account_ledger.transaction_id, :anchor => 'payments')
      end
    elsif account_ledger.ac_id == account_ledger.account_id
      "/account_ledgers/#{account_ledger.id}?ac_id=#{account_ledger.to_id}"
    else
      "/account_ledgers/#{account_ledger.id}?ac_id=#{account_ledger.account_id}"
    end
  end

  # Creates a link for a contact
  def contact_account_type_link(account, type)
    ac = account.original_type.downcase.pluralize
    case type
    when :plural  then "/#{ac}"
    when :new     then "/#{ac}/new"
    when :edit    then "/#{ac}/#{account.accountable_id}/edit"
    when :destroy then "/#{ac}/#{account.accountable_id}"
    end
  end

  def show_account_partial(tab)
    case tab
    when 'incomes' then ''
    else 'account_ledgers/contact'
    end
  end

  def present_amount(amount, tag = "h3")
    css, title = amount >= 0 ? ["dark_green", "Nos debe"] : ["red", "Se debe"]
    content_tag(tag, ntc(amount), :class => "tip #{css}", :title => title)
  end

  def account_ledger_show_links(al)
    case al.selected_account.original_type
    when "Client"
      render "account_ledgers/contact_links", :plural => "Clientes", :path => "/clients"
    when "Supplier"
      render "account_ledgers/contact_links", :plural => "Proveedores", :path => "/supliers"
    when "Staff"
      render "account_ledgers/contact_links", :plural => "Personal", :paht => "/staffs"
    when "Bank"
      render "account_ledgers/money_links", :plural => "Cuentas bancarias", :path => "/banks"
    when "Cash"
      render "account_ledgers/money_links", :plural => "Cuenas caja", :path => "/cashes"
    end
  end

  def ledger_amount(ledger, account)
    if ledger.account_id === account.id
      ledger.amount
    else
      ledger.amount_currency
    end
  end

  def balance_amount(ledger, account)
    if ledger.account_id === account.id
      ntc ledger.account_balance unless ledger.account_balance.blank?
    else
      ntc ledger.to_balance unless ledger.to_balance.blank?
    end
  end

  def link_related_ledger_account(al, money)
    if al.transaction_id.present?
      link_to al.transaction, al.transaction
    else
      ac = al.account_accountable_id == money.id ? :to : :account

      if al.operation === 'trans'
        link_to al.send(ac), get_ledger_money_url(al.send(ac))
      else
        link_to al.send(ac), get_ledger_contact_url(al.send(ac))
      end
    end
  end

  def get_ledger_money_url(ac)
    case ac.original_type
    when "Bank"
      "/banks/#{ac.accountable_id}"
    when "Cash"
      "/cashes/#{ac.accountable_id}"
    end
  end

  def get_ledger_contact_url(ac)
    case ac.original_type
    when "Client"
      "/clients/#{ac.accountable_id}"
    when "Supplier"
      "/suppliers/#{ac.accountable_id}"
    when "Staff"
      "/staffs/#{ac.accountable_id}"
    end
  end

  def red_pendent_account_link(account, options = {})
    count = account.get_ledgers.pendent.count

    if count > 0
      txt = "Tiene (#{count})"
      txt << ( count > 1 ? " transaccciones" : " transacción" )
      txt << " Esperando verificación"
      link_to txt, url_for(params.merge(:option => 'uncon')), options
    end
  end
end
