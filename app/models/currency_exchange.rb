# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Makes the exchange and can check validation for conversion in
# account_ledgers, the accounts passed should be valid
class CurrencyExchange

  attr_accessor :account, :account_to, :exchange_rate

  delegate :currency, to: :current_organisation
  delegate :currency, to: :account, prefix: true, allow_nil: true
  delegate :currency, to: :account_to, prefix: true, allow_nil: true

  def initialize(attrs = {})
    attrs.each do |k, v|
      send(:"#{k}=", v)
    end

    self.exchange_rate = 1  if same_currency?
  end

  def inverse?
    account_currency != currency && account_currency != account_to_currency
  end

  def valid?
    (account_currency == currency || account_to_currency == currency || same_currency?)
  end

  def exchange(val = 1)
    ret = if inverse?
            val * 1 / exchange_rate
          else
            val * exchange_rate
          end

    ret.round(4)
  end

  def attributes
    { account: account, account_to: account_to, exchange_rate: exchange_rate }
  end

  def same_currency?
    account_currency == account_to_currency
  end

  private

    def current_organisation
      OrganisationSession
    end
end

