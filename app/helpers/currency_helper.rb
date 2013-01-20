# Methods for currency
# currency method is defined in application controller, and is the currency the organisation uses
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

  def currency_name(cur=currency)
    CURRENCIES[cur].fetch(:name)
  end

  def currency_plural
  end

  def currency_symbol(cur=currency)
    CURRENCIES[cur].fetch(:symbol)
  end

  def currency_label(cur=currency)
    "<span class='label label-inverse' title='#{CURRENCIES[cur].fetch(:name)}' rel='tooltip'>#{cur}</span>".html_safe
  end


  # defined in ApplicationController
  #def currency
  #  current_organisation.currency
  #end
end
