# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::Form < Movements::Form
  alias_method :income, :movement

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :income_details,
           :subtotal, :to_s, :state, :discount, :details,
           :income_details_attributes, :income_details_attributes=, :taxes,
           to: :income

  delegate :id, to: :income, prefix: true
  delegate :create, :create_and_approve, :update, :update_and_approve,
           to: :income

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    _object = new(attrs.slice(*ATTRIBUTES))
    _object.movement = Incomes::Service.new_income(attrs)
    _object.movement.direct_payment = _object.direct_payment
    _object
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    _object = new
    _object.set_service_attributes(Income::Service.find(id))
    _object
  end


  def update_and_approve(attrs = {})
    @movement.approve!

    update attrs
  end

  def set_new_income(attrs = {})
    @movement = Income.new_income
    MovementService.new(@movement).set_new(attrs)
    copy_new_defaults
  end

  private

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
