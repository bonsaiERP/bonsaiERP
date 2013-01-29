# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Makes the exchange and can check validation for conversion in
# account_ledgers
class CurrencyExchange

  attr_accessor :account, :account_to, :exchange_rate

  delegate :currency, to: :current_organisation

  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send(:"#{k}=", v)
    end
  end

  def inverse?
    account_to.currency != currency
  end

  def valid?
    account.currency === currency || account_to.currency === currency
  end

  def exchange(val = 1)
    ret = if inverse?
            val * 1/exchange_rate
          else
            val * exchange_rate
          end

    ret.round(4)
  end

private
  def current_organisation
    OrganisationSession
  end
end

