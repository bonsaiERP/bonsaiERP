# Methods for currency
# currency method is defined in application controller, and is the currency the organisation uses
module CurrencyHelper
  # ApplicationController#currency method is defined

  def currency_options
    Currency.options *Currency::FILTER
  end

  def currency_name(cur = currency)
    CURRENCIES[cur].fetch(:name)
  end

  def currency_symbol(cur = currency)
    CURRENCIES[cur].fetch(:symbol)
  end

  def currency_label(cur = currency)
    "<span class='label label-inverse' title='#{CURRENCIES[cur].fetch(:name)}' rel='tooltip'>#{cur}</span>".html_safe
  end
end
