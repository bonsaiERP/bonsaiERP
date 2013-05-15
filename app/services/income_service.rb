# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomeService < TransactionService
  alias :income :transaction

  INCOME_ATTRIBUTES = TRANS_ATTRIBUTES + [:income_details_attributes]

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :income_details, 
           :subtotal, :to_s, :state, :discount, to: :income

  delegate :id, to: :income, prefix: true

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    is = new(attrs.slice(*ATTRIBUTES))
    is.set_income(attrs.slice(*INCOME_ATTRIBUTES))
    is
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    is = new
    is.set_service_attributes(Income.find(id))
    is
  end

  # Creates and can call other methods passed in the block
  def create
    set_income_data
    create_or_update { income.save }
  end

  # Creates  and approves an Income
  def create_and_approve
    set_income_data

    create_or_update do
      income.approve!
      income.amount = 0 if direct_payment?

      income.set_state_by_balance!
      res = income.save
      res = res && create_ledger if direct_payment?

      res
    end
  end

  def update(attrs = {})
    self.attributes = attrs

    create_or_update do
      res = TransactionHistory.new.create_history(income)
      income.attributes = attrs.slice(*INCOME_ATTRIBUTES)
      update_income_data

      income.save && res
    end
  end

  def update_and_approve(attrs = {})
    self.attributes = attrs

    create_or_update do
      income.approve!
      res = TransactionHistory.new.create_history(income)
      income.attributes = attrs.slice(*INCOME_ATTRIBUTES)

      update_income_data
      income.amount = 0 if direct_payment?
      income.set_state_by_balance!

      res = income.save && res

      res = res && create_ledger if direct_payment?

      res
    end
  end

  def set_income(attrs = {})
    @transaction = Income.new_income(attrs.merge(
      ref_number: Income.get_ref_number,
      date: attrs[:date] || Date.today,
      currency: attrs[:currency] || OrganisationSession.currency
    ))
    @transaction.income_details.build if @transaction.income_details.empty?
  end

private
  # Creates or updates and sets errors messages in case of failing
  def create_or_update(&b)
    res = valid?
    res = income.valid? && res

    res = commit_or_rollback { b.call } if res

    set_errors(*[income, ledger].compact) unless res

    res
  end

  # Updates the data for an imcome
  # total is the alias for amount due that Income < Account
  def update_income_data
    set_income_details
    income.balance -= (income.total_was - income.total)
    income.gross_total = original_income_total
    income.set_state_by_balance!
    income.discounted = ( discount > 0 )

    IncomeErrors.new(income).set_errors
  end

  # For new income
  def set_income_data
    set_income_details

    income.ref_number  = Income.get_ref_number
    income.gross_total = original_income_total
    income.amount      = income.total
    income.state       = 'draft'
    income.discounted  = ( discount > 0 )
    income.creator_id  = UserSession.id
  end

  # Set details for a new Income
  def set_income_details
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance        = get_detail_balance(det)
    end
  end

  def get_detail_balance(det)
    det.balance - (det.quantity_was - det.quantity)
  end

  def original_income_total
    income_details.inject(0) {|sum, det| sum += det.quantity.to_f * det.original_price.to_f }
  end

  # Saves the ledger with transaction data
  def create_ledger
    @ledger = BuildServiceLedger.new(self).ledger
    @ledger.save_ledger
  end

  def income_is_valid
    self.errors.add :base, I18n.t('errors.messages.income.not_draft') unless income.is_draft?
  end

  def valid_account_to
    self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end
end

class BuildServiceLedger < Struct.new(:income_service)
  delegate :reference, :account_to_id, :date, :income, to: :income_service

  def ledger
    AccountLedger.new(
      account_id: income.id, amount: income.total,
      account_to_id: account_to_id, date: date,
      operation: 'payin', status: 'approved',
      exchange_rate: 1, currency: income.currency, inverse: false,
      reference: get_reference
    )
  end

  def get_reference
    reference.present? ? reference : I18n.t('income.payment.reference', income: income)
  end
end
