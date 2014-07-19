# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::Form < Movements::Form
  alias_method :expense, :movement

  attribute :expense_details_attributes

  validate :expense_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :expense_details, :total,
           :subtotal, :to_s, :state, :discount, :details,
           to: :expense

  delegate :id, to: :expense, prefix: true

  # Creates and instance of income and initializes
  def self.new_expense(attrs = {})
    _object = new(Expense::EXTRAS_DEFAULTS.merge(attrs))
    _object.set_new_expense(attrs)
    _object
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    _object = new
    _object.movement   = Expense.find(id)
    _object.service    = Expenses::Service.new(_object.expense)
    _object.attributes = _object.expense.attributes
    _object
  end

  def set_new_expense(attrs = {})
    set_defaults
    @movement = Expense.new(expense_attributes)
    @movement.ref_number = Expense.get_ref_number
    @movement.state = 'draft'
    @movement.error_messages = {}
    @movement.inventory = OrganisationSession.inventory?
    2.times { @movement.expense_details.build(quantity: 1) }  if expense.details.empty?
    @service = Expenses::Service.new(expense)
  end

  def expense_attributes
    attrs = attributes.except(:account_to_id, :direct_payment, :reference)
    attrs[:tag_ids] = Array(attrs[:tag_ids]).map(&:to_i)  if attrs[:tag_ids]
    attrs[:expense_details_attributes] ||= []
    attrs
  end

  def form_details_name
    'expenses_form[expense_details_attributes]'
  end

  def is_income?; false; end

  private

    def expense_is_valid
      self.errors.add :base, I18n.t('errors.messages.expense.payments') unless expense.total === expense.balance
    end

    def valid_account_to
      self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
    end

    def account_to
      @account_to ||= Accounts::Query.new.money.where(currency: currency, id: account_to_id).first
    end
end
