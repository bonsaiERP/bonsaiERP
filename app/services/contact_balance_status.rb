# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactBalanceStatus < Struct.new(:transactions)
  attr_reader :h
  delegate :currency, to: OrganisationSession

  # Creates a hash with the balance by currency
  def create_balances
    @h = { 'TOTAL' => calculate_total }
    return @h if transactions.empty?
    set_base_currency
    set_other_currencies

    @h
  end

  # Receives a Income or Expense instance and calculates
  # the balance for each currency
  def object_balance(obj)
    create_balances

    @h['TOTAL'] = (@h['TOTAL'] + (obj.amount) * obj.exchange_rate).round(2)
    @h[obj.currency] = ((@h[obj.currency] || 0.0) + obj.amount).round(2)

    @h
  end

  private

    def set_base_currency
      if base_currency_transaction && base_currency_transaction.tot.to_d != 0.0
        @h[currency] =  base_currency_transaction.tot.to_d.round(2)
      end
    end

    def set_other_currencies
      other_currencies_transactions.each do |trans|
        @h[trans.currency] = trans.tot_cur.to_d.round(2) if trans.tot_cur.to_d != 0.0
      end
    end

    def calculate_total
      transactions.inject(0) { |sum, trans| sum += trans.tot.to_d }.round(2)
    end

    def base_currency_transaction
      @base_currency_transaction ||= transactions.find { |v| v.currency === currency }
    end

    def other_currencies_transactions
      @other_currencies_transactions ||= transactions.select {|v| v.currency != currency }
    end
end
