module CurrenciesHelper
  def with_currency(klass, amount = :amount, options = {})
    options = {:precision => 2}.merge(options)
    "#{ klass.currency_symbol } #{number_to_currency klass.send(amount), options}"
  end

end
