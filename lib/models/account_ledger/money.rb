module Models::AccountLedger
  module Money
    def self.extended(base)
      base.class.instance_eval do
        attr_accessor :account_to, :reference
        validates_presence_of :account_to

        validates_numericality_of :amount
      end
    end

    def currency
      ::Account.find(account_id).currency_symbol
    end

    def income?
      case operation
        when "in" then true
        when "out" then false
      end

    end
  end
end
