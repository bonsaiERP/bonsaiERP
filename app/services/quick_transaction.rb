# encoding: utf-8
# Generates a quick income with all data
class QuickTransaction
  include Virtus

  attr_reader :income, :account_ledger

  attribute :ref_number  , String
  attribute :currency_id , Integer
  attribute :account_id  , Integer
  attribute :contact_id  , Integer
  attribute :date        , Date
  attribute :amount      , Decimal
  attribute :bill_number , String
  attribute :fact        , Boolean

  def initialize(attributes = {})
    super attributes
    self.ref_number = ref_number || Income.get_ref_number
    self.fact = [true, false].include?(fact) ? fact : true
    self.date = date || Date.today
  end

  def create_in
    ActiveRecord::Base.transaction do
      create_income

      create_account_ledger
    end
  rescue Exception => e

    false
  end

  def create_out
    ActiveRecord::Base.transaction do
      create_expense(-1)

      create_account_ledger
    end
  rescue Exception => e

    false
  end

  private
    def create_income
      @income = Income.new(income_attributes) do |inc|
        inc.total = inc.gross_total = inc.original_total = amount
        inc.balance = 0
      end

      @income.save!
    end

    def income_attributes
      {ref_number: ref_number, date: date, currency_id: currency_id,
       bill_number: bill_number, fact: fact, contact_id: contact_id }
    end

    def create_account_ledger(amount_sign = 1)
      amt = amount * amount_sign
      @account_ledger = AccountLedger.new(
        amount: amt, account_id: account_id,
        reference: "#{income.ref_number}", operation: 'pin',
        exchange_rate: 1, contact_id: contact_id
      ) do |al|
        al.currency_id = currency_id
        al.transaction_id = income.id
        al.conciliation = true
      end

      @account_ledger.save!
    end
end
