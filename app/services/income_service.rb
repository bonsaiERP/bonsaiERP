# encoding: utf-8
class IncomeService < TransactionService
  attr_accessor :income, :ledger

  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :income_details, 
    :income_details_attributes, :income_details_attributes=,
    :subtotal, :to_s, :state, :discount, to: :income

  delegate :id, to: :income, prefix: true

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    attrs = set_new_income_attributes(attrs)
    is = new(attrs) do |i|
      i.income = Income.new_income(attrs.except(:direct_payment, :account_to_id, :income_details_attributes))
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
      is.income = inc
    end
  end

  # Creates and can call other methods passed in the block
  def create
    set_income_data

    create_or_update do
      income.save
    end
  end

  # Creates  and approves an Income
  def create_and_approve
    build_ledger if can_pay?
    set_income_data
    income.approve!

    create_or_update do
      res = income.save
      res = res && create_ledger
      income.state = income.state_was || 'draft' unless res

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
    build_ledger if can_pay?
    income.approve!

    create_or_update do
      res = TransactionHistory.new.create_history(income)
      income.attributes = income_attributes

      update_income_data
      res = income.save && res

      res = res && create_ledger
      income.state = income.state_was || 'draft' unless res

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
    res = commit_or_rollback { b.call } && res

    set_errors(*[income, ledger].compact) unless res

    res
  end

  def income_attributes
    attributes.except(:direct_payment, :account_to_id, :income_details_attributes)
  end

  # Updates the data for an imcome
  # total is the alias for amount due that Income < Account
  def update_income_data
    income.balance -= (income.total_was - income.total)
    update_details
    income.gross_total = original_income_total
    income.set_state_by_balance!
    income.discounted = ( discount > 0 )

    set_paid_income if ledger.present?

    IncomeErrors.new(income).set_errors
  end

  def set_income_data
    set_new_details
    income.ref_number = Income.get_ref_number
    income.gross_total = original_income_total
    income.balance = income.total
    income.state = 'draft' if state.blank?
    income.discounted = ( discount > 0 )
    income.creator_id = UserSession.id

    set_paid_income if ledger.present?
  end

  def set_paid_income
    income.balance = 0
    income.state = 'paid'
  end

  # Set details for a new Income
  def set_new_details
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance = get_detail_balance(det)
    end
  end

  def update_details
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance = get_detail_balance(det)
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
    income_details.inject(0) do |sum, det|
      sum += det.quantity.to_f * det.original_price.to_f
    end
  end

  def item_ids
    @item_ids ||= income_details.map(&:item_id)
  end

  # Creates a ledger if it can pay
  def build_ledger
    @ledger = AccountLedger.new(
      account_to_id: account_to_id, date: date,
      operation: 'payin', exchange_rate: 1,
      currency: income.currency, inverse: false
    )
  end

  # Saves the ledger with income data
  def create_ledger
    return true unless ledger.present?
    ledger.account_id = income.id
    ledger.amount = income.total
    ledger.reference = "Cobro ingreso #{income}"

    ledger.save_ledger
  end

  def can_pay?
    income.is_draft? && direct_payment?
  end

  def valid_account_to
    unless account_to.present?
      self.errors.add :account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')
    end
  end

  def direct_payment?
    direct_payment == true
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end

end
