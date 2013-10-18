# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::Form < Movements::Form
  alias :income :movement

  attr_accessor :income_details_attributes

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :total,
           :subtotal, :to_s, :state, :discount, :details,
           :income_details,
           to: :income

  delegate :id, to: :income, prefix: true

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    _object = new(attrs.slice(*ATTRIBUTES))
    #_object.attr_details = attrs[:income_details_attributes]
    _object.set_new_income
    _object
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    _object = new
    _object.movement   = Income.find(id)
    _object.service    = Incomes::Service.new(_object.income)
    _object.attributes = _object.income.attributes
    _object
  end

  def set_new_income
    set_defaults
    @movement = Income.new(movement_create_attributes.merge(income_details_attributes: attr_details))
    2.times { @movement.income_details.build(quantity: 1) }  if income.details.empty?
    @service = Incomes::Service.new(income)
  end

  private

    def build_ledger
      @ledger = AccountLedger.new(
        account_id: income.id, amount: income.total,
        account_to_id: account_to_id, date: date,
        operation: 'payin', exchange_rate: 1,
        currency: income.currency, inverse: false,
        reference: get_reference
      )
    end

    def get_reference
      reference.present? ? reference : I18n.t('income.payment.reference', income: income)
    end

    def income_is_valid
      self.errors.add :base, I18n.t('errors.messages.income.payments') unless income.total === income.balance
    end

    def valid_account_to
      self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
    end

    def account_to
      @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
    end
end
