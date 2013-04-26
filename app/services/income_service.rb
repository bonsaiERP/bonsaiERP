# encoding: utf-8
class IncomeService < TransactionService
  attr_accessor :income, :ledger

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :income_details, 
    :income_details_attributes, :income_details_attributes=,
    :subtotal, :to_s, :state, :discount, to: :income

  delegate :id, to: :income, prefix: true

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    attrs = set_new_income_attributes(attrs)
    is = new(attrs) do |i|
      i.income = Income.new_income(attrs.except(:direct_payment, :account_to_id, :income_details_attributes, :reference))
    end
    is.income_details.build(quantity: 1) if is.income_details.empty?

    is
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    inc = Income.find(id)
    new(inc.attributes) do |is|
      is.ref_number = inc.ref_number
      is.total = inc.total
      is.due_date = inc.due_date
      is.income = inc
    end
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
      income.attributes = income_attributes
      update_income_data

      income.save && res
    end
  end

  def update_and_approve(attrs = {})
    self.attributes = attrs

    create_or_update do
      income.approve!
      res = TransactionHistory.new.create_history(income)
      income.attributes = income_attributes

      update_income_data
      income.amount = 0 if direct_payment?
      income.set_state_by_balance!

      res = income.save && res

      res = res && create_ledger if direct_payment?

      res
    end
  end

  # Sets the expense params when new_record
  def self.set_new_income_attributes(attrs)
    attrs[:ref_number] = Income.get_ref_number if attrs[:ref_number].blank?
    attrs[:date] = Date.today if attrs[:date].blank?
    attrs[:currency] = OrganisationSession.currency if attrs[:currency].blank?
    attrs
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

  def income_attributes
    attributes.except(:direct_payment, :account_to_id, :income_details_attributes, :reference)
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

  def set_details_original_prices
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def original_income_total
    income_details.inject(0) {|sum, det| sum += det.quantity.to_f * det.original_price.to_f }
  end

  def item_ids
    @item_ids ||= income_details.map(&:item_id)
  end

  # Saves the ledger with income data
  def create_ledger
    @ledger = AccountLedger.new(
      account_id: income.id, amount: income.total,
      account_to_id: account_to_id, date: date,
      operation: 'payin', status: 'approved',
      exchange_rate: 1, currency: income.currency, inverse: false,
      reference: get_reference
    )

    @ledger.save_ledger
  end

  def get_reference
    reference.present? ? reference : I18n.t('income.payment.reference', income: income)
  end

  def income_is_valid
    self.errors.add :base, I18n.t('errors.messages.income.not_draft') unless income.is_draft?
  end

  def valid_account_to
    self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
  end

  def direct_payment?
    direct_payment === true
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end
end
