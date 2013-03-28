# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Currency < OpenStruct

  FILTER = %w(USD EUR ARS BOB CLP COP MXN PYG PEN UYU VEB GBP JPY)

  def to_s
    "#{code} #{name}"
  end

  def self.find(cur)
    if CURRENCIES[cur]
      Currency.new(CURRENCIES[cur])
    else
      nil
    end
  end

  def self.all
    CURRENCIES.map {|v| Currency.new(v) }
  end

  def self.options(*currencies)
    currencies.map do |k|
      cur = Currency.new(CURRENCIES[k])
      [cur.to_s, k]
    end
  end
end
