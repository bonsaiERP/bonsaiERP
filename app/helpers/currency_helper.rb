module CurrencyHelper
  def _currency
    Currency.new
  end

  def currency_options
    _currency.options
  end

  def currency_options_filtered
    _currency.options_filtered
  end

  def currency_name
    CURRENCIES[currency].fetch(:name)
  end

  def currency_plural
  end

  def currency_symbol
    CURRENCIES[currency].fetch(:symbol)
  end


  def currency_label(curr = currency)
    "<span class='label label-inverse' title='#{CURRENCIES[curr].fetch(:name)}' rel='tooltip'>#{curr}</span>".html_safe
  end

  def currency_code
    currency
  end

  # defined in ApplicationController
  #def currency
  #  current_organisation.currency
  #end
end
