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
    "#{text_label} (#{klass.currency_symbol} #{klass.currency_name.pluralize})"
  end

  def list_taxes(klass)
    klass.taxes.map(&:abbreviation).join(" + ")
  end

end
