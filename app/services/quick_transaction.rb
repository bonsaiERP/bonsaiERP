# encoding: utf-8
# Generates a quick income with all data
class QuickTransaction < BaseService
  include Virtus

  attr_reader :income, :expense, :account_ledger,:transaction, :contact

  attribute :ref_number  , String
  #attribute :currency_id , Integer
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
    self.amount = amount.to_f.abs
  end

  def create_in
    res = true
    ActiveRecord::Base.transaction do
      res = create_income

      res = create_income_ledger && res

      unless res
        set_errors(:income, :account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

  def create_out
    res = true
    ActiveRecord::Base.transaction do
      res = create_expense
 
      res = create_expense_ledger && res

      unless res
        set_errors(:income, :account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

private
  def create_income
    @income = @transaction = Income.new(income_attributes) do |inc|
      inc.total = inc.gross_total = inc.original_total = amount
      inc.balance = amount
    end

    @income.save
  end

  def create_expense
    @expense = @transaction = Expense.new(income_attributes) do |inc|
      inc.total = inc.gross_total = inc.original_total = amount
      inc.balance = amount
    end

    @expense.save
  end

  def income_attributes
    {ref_number: ref_number, date: date, currency_id: currency_id,
     bill_number: bill_number, fact: fact, contact_id: contact_id }
  end

  def create_income_ledger
    @account_ledger = AccountLedger.new(
      amount: amount, account_id: account_id,
      reference: "#{transaction.ref_number}", operation: 'pin',
      exchange_rate: 1, contact_id: contact_id
    ) do |al|
      al.transaction_id = income.id
      al.conciliation = true
    end

    @account_ledger.save
  end

  def create_expense_ledger
    @account_ledger = AccountLedger.new(
      amount: -amount, account_id: account_id,
      reference: "#{transaction.ref_number}", operation: 'pout',
      exchange_rate: 1, contact_id: contact_id
    ) do |al|
      al.currency_id = currency_id
      al.transaction_id = expense.id
      al.conciliation = true
    end

    @account_ledger.save
  end

  def account
    @account ||= Account.find_by_id(account_id)
  end

  def currency_id
    if account.present?
      account.currency_id
    else
      nil
    end
  end
end
