# author: Boris Barroso
# email: boriscyber@gmail.com
# Base class for Income and Expense
class Movement < Account

  # module for setters and getters
  extend Models::AccountCode

  STATES = %w(draft approved paid nulled)
=begin
  jsonb_accessor(:extras,
    {delivered: :boolean,
    discounted: :boolean,
    devolution: :boolean,
    gross_total: :decimal,
    inventory: :boolean,
    balance_inventory: :decimal,
    original_total: :decimal,
    bill_number: :string,
    null_reason: :string,
    operation_type: :string,
    nuller_datetime: :datetime,
    approver_datetime: :datetime})
=end
  EXTRAS_DEFAULTS = {
    delivered: false,
    discounted: false,
    devolution: false,
    gross_total: 0.0,
    inventory: true,
    balance_inventory: 0.0,
    original_total: 0.0,
    bill_number: '',
    null_reason: '',
    operation_type: '',
    nuller_datetime: nil,
    approver_datetime: nil
  }

  # Callbacks
  before_update :check_items_balances

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_many :ledgers, foreign_key: :account_id, class_name: 'AccountLedger'
  has_many :inventories, foreign_key: :account_id

  ########################################
  # Validations
  validates_presence_of :date, :due_date, :contact, :contact_id
  validates :state, presence: true, inclusion: {in: STATES}
  validate  :valid_currency_change, on: :update
  validate  :greater_or_equal_due_date

  ########################################
  # Delegations
  delegate :name, :percentage, :percentage_dec, to: :tax, prefix: true, allow_nil: true

  # Define boolean methods for states
  STATES.each do |_state|
    define_method :"is_#{_state}?" do
      _state == state
    end
  end

  def self.movements
    Account.where(type: ['Income', 'Expense'])
  end

  ########################################
  # Aliases, alias and alias_method not working
  [[:ref_number, :name], [:balance, :amount]].each do |meth|
    define_method meth.first do
      self.send(meth.last)
    end

    define_method :"#{meth.first}=" do |val|
      self.send(:"#{meth.last}=", val)
    end
  end

  def to_s
    ref_number
  end

  def to_param
    "#{id}-#{ref_number}"
  end

  def set_state_by_balance!
    if balance <= 0
      self.state = 'paid'
    elsif balance != total
      self.state = 'approved'
    elsif state.blank?
      self.state = 'draft'
    end
  end

  def paid
    if balance >= 0
      total - balance
    else
      -(balance - total)
    end
  end

  def discount
    gross_total - total
  end

  def discount_percent
    discount/gross_total
  end

  def approve!
    if is_draft?
      self.state = 'approved'
      self.approver_id = UserSession.id
      self.approver_datetime = Time.zone.now
      self.due_date ||= Time.zone.now.to_date
      self.extras = extras.symbolize_keys
    end
  end

  def null!
    if can_null?
      update_attributes(state: 'nulled', nuller_id: UserSession.id, nuller_datetime: Time.zone.now)
    end
  end

  def can_null?
    return false  if is_draft? || is_nulled?
    return false  if ledgers.pendent.any?
    return false  if inventory_was_moved?
    total === amount
  end

  def inventory_was_moved?
    details.any? { |det| det.quantity != det.balance }
  end

  def details
    []
  end

  def can_pay?
    !is_nulled? && !is_paid? && !is_draft?
  end

  def can_devolution?
    return false  if is_draft? || is_nulled?
    return false  if balance == total

    true
  end

  def is_active?
    is_approved? || is_paid?
  end

  def taxes
    subtotal * tax_percentage/100
  end

  #alias_method :old_attributes, :attributes
  #def attributes
  #  old_attributes.merge(
  #    Hash[ hstore_metadata_for_extras.keys.map { |key| [key.to_s, self.send(key)] } ]
  #  )
  #end

  private

    def nulling_valid?
      ['paid', 'approved'].include?(state_was) && is_nulled?
    end

    # Do not allow items to be destroyed if the quantity != balance
    def check_items_balances
      details.select(&:marked_for_destruction?)
      .all?(&:valid_for_destruction?)
    end

   def valid_currency_change
     errors.add(:currency, I18n.t('errors.messages.movement.currency_change'))  if currency_changed? && ledgers.any?
   end

   def greater_or_equal_due_date
     errors.add(:due_date, I18n.t('errors.messages.movement.greater_due_date'))  if date && due_date && due_date < date
   end

end
