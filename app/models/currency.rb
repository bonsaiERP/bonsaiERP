# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Currency

  FILTER_CURRENCIES = %w(BOB USD EUR)

  def list
    CURRENCIES
  end

  def options(curr = CURRENCIES)
    curr.map {|k,v| ["#{k} #{v.fetch(:name)}", k]}
  end

  def options_filtered(filter = FILTER_CURRENCIES)
    options(CURRENCIES.slice(*filter) )
  end
end
