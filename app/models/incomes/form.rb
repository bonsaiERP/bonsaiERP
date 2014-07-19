# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::Form < Movements::Form
  alias_method :income, :movement

  attribute :income_details_attributes

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :total,
           :subtotal, :to_s, :state, :discount, :details,
           :income_details,
           to: :income

  delegate :id, to: :income, prefix: true

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    _object = new(Income::EXTRAS_DEFAULTS.merge(attrs))
    _object.set_new_income
    _object
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    _object = new
    _object.movement   = Income.find(id)
    _object.service    = Incomes::Service.new(_object.income)
    _object.attributes = _object.get_movement_attributes
    _object
  end

  def set_new_income
    set_defaults
    set_new_income_data
    @service = Incomes::Service.new(income)
  end

  def income_attributes
    attrs = attributes.except(:account_to_id, :direct_payment, :reference)
    attrs[:tag_ids] = Array(attrs[:tag_ids]).map(&:to_i)  if attrs[:tag_ids]
    attrs[:income_details_attributes] ||= []
    attrs
  end

  def form_name
    'incomes_form'
  end

  def form_details_name
    'incomes_form[income_details_attributes]'
  end

  def is_income?; true; end

  def income_form_attributes
    income.attributes.slice()
  end

  private

    def set_defaults
      super
      income_details_attributes ||= []
    end

    def income_is_valid
      self.errors.add :base, I18n.t('errors.messages.income.payments') unless income.total === income.balance
    end

    def valid_account_to
      self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
    end

    def account_to
      @account_to ||= Accounts::Query.new.money.where(currency: currency, id: account_to_id).first
    end

    def set_new_income_data
      @movement = Income.new(income_attributes.merge(self.class.new_income_attributes))

      2.times { @movement.income_details.build(quantity: 1) }  if income.details.empty?
    end

    def self.new_income_attributes
      { state: 'draft',
        ref_number: Income.get_ref_number,
        error_messages: {},
        inventory: OrganisationSession.inventory?
      }
    end
end
