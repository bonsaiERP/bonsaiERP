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
    "<span class='label bg-black' title='#{CURRENCIES[cur].try(:fetch, :name)}' data-toggle='tooltip'>#{cur}</span>".html_safe
  end

  alias :currency_tag :currency_label

  def negative_tag(val)
    if val < 0
    "<span class='text-error'>#{ntc val}</span>".html_safe
    else
      val
    end
  end

  def minimum_stock_tag(stock)
    if stock.quantity < stock.minimum
      "<span class='text-error'>#{ntc stock.quantity}</span>".html_safe
    else
      ntc stock.quantity
    end
  end
end
