module CurrenciesHelper
  def with_currency(klass, amount, options = {})
    options = {:precision => 2}.merge(options)
    "#{ klass.currency_symbol } #{number_to_currency amount, options}"
  end

end
