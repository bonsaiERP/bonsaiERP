# encoding: utf-8
module TransactionsHelper
  def cash(cash)
    if cash
      "al contado"
    else
      "a crédito"
    end
  end

  def total_currency(transaction)
    ntc(transaction.total_currency) unless session[:organisation][:currency_id] == transaction.currency_id
  end

  # Transforms to the default currency
  # @param Transaction
  # @param Symbol
  # @param Hash
  # @return String
  def exchange(klass, method, currencies)
    unless klass.currency_id == currency_id
      rate = currencies[klass.currency_id].round(2)
      klass.send(method) * rate
    else
      klass.send(method)
    end
  end

  def show_money(klass, amount, options = {})
    options = {:precision => 2}.merge(options)
    unless klass.currency_id == session[:organisation][:currency_id]
      "#{ klass.currency_symbol } #{number_to_currency amount, options}"
    else
      number_to_currency(amount, options)
    end
  end

  # Adds the currency to the label
  # @param String
  # @param Object [Transaction, Payment, PayPlan, ..]
  def currency_label(text_label, klass)
    "#{text_label} <span>(#{klass.currency_symbol})</span>"
  end

  def list_taxes(klass)
    klass.taxes.map(&:abbreviation).join(" + ")
  end

  # Indicates if there was a price change only for Income
  def price_change(klass)
    if klass.changed_price?
      "<span class='dark_grey tip' title='Precio original: #{ntc klass.original_price}' >#{ntc klass.price}</span>".html_safe
    else
      ntc klass.price
    end
  end

  # Label for contacts in transaction form
  def contact_label
    if params[:controller] == 'incomes'
      "Cliente"
    else
      "Proveedor"
    end
  end

  def credit_tab_title(trans)
    trans.credit? ? "Crédito" : "Aprobar crédito"
  end

  def get_credit_partial(trans)
    if trans.income?
      trans.credit? ? "pay_plans/pay_plans" : "pay_plans/approve"
    else
      "pay_plans/pay_plans"
    end
  end

  # Returns the path for contacts
  def cont_path
    if params[:controller] == 'incomes'
      "/clients"
    else
      "/suppliers"
    end
  end

  # Returns the title for transaction
  def transaction_title(klass)
    if klass.draft?
      "Proforma de #{klass.get_type}"
    else
      "Nota de #{klass.get_type}"
    end
  end

  def transaction_type(op = nil)
    op ||= params[:controller]
    case op
    when "incomes", "Income"   then "Ventas"
    when "buys", "Buy"         then "Compras"
    when "expenses", "Expense" then "Gastos"
    end
  end

  # Returns if the organisation has to pay or recive a payment
  def transaction_pay_method
    if params[:controller] == "incomes"
      "Cobros"
    else
      "Pagos"
    end
  end

  def note_title(income)
    if income.state == "draft"
      "Proforma"
    else
      "Nota"
    end
  end

  def cash_credit(cash)
    if cash
      image_tag("money.png", :title => "Contado", :class => 'tip')
    else
      image_tag("credit.png", :title => "Crédito", :class => 'tip')
    end
  end

  def payment_type(trans)
    case trans.class.to_s
    when "Income" then "cobro"
    when "Buy", "Expense" then "pago"
    end
  end

  # Links for incomes
  def link_incomes(text, option, options = {})
    params[:option] = 'all' if params[:option].nil?
    active = (params[:option] == option) ? "active" : ""
    link_to text, incomes_path(:option => option), options.merge(:class => active)
  end

  def list_income_states
    [
      ["Todas", "all"], 
      ["Esperando aprobación", "draft"], 
      ["Esperando cobro", "awaiting_payment"], 
      ["Vencidas", "due"], 
      ["Con inventario pendiente", "inventory"], 
      ["Cobradas", "paid"]
    ]
  end

  def list_buy_states
    [
      ["Todas", "all"], 
      ["Esperando aprobación", "draft"], 
      ["Esperando pago", "awaiting_payment"], 
      ["Vencidas", "due"], 
      ["Con inventario pendiente", "inventory"], 
      ["Pagadas", "paid"]
    ]
  end


  def list_expense_states
    [
      ["Todas", "all"], 
      ["Esperando aprobación", "draft"], 
      ["Esperando pago", "awaiting_payment"], 
      ["Vencidas", "due"], 
      ["Pagadas", "paid"]
    ]
  end

  # Shows the new_link only to priviledged users
  def can_show_new_pay_plan_link?(klass)
    if klass.draft?
      true
    else
      if User.admin_gerency?(session[:user][:role])
        true
      else
        false
      end
    end
  end

  def get_contact_list
    case params[:controller]
      when "incomes"          then ["Client", "Supplier", "Staff"]
      when "buys", "expenses" then ["Supplier", "Client", "Staff"]
    end
  end

  def payment_title(trans)
    case trans.class.to_s
    when "Income" then "Cobro"
    when "Buy", "Expense" then "Pago"
    end
  end
end
