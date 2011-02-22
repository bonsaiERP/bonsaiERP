module CurrenciesHelper
  def with_currency(klass, amount)
    unless klass.currency_id == session[:organisation][:currency_id]
      "#{ klass.currency_symbol } #{nwd amount}"
    else
      nwd(amount)
    end
  end

end
