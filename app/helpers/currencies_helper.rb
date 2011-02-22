module CurrenciesHelper
  def with_currency(klass, amount, options = {})
    options = {:precision => 2}.merge(options)
    unless klass.currency_id == session[:organisation][:currency_id]
      "#{ klass.currency_symbol } #{number_to_currency amount, options}"
    else
      number_to_currency(amount, options)
    end
  end

end
