# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movement < Account

  # module for setters and getters
  extend SettersGetters
  extend Models::AccountCode

  STATES = %w(draft approved paid nulled)

  # Store
  EXTRA_COLUMNS = %i(bill_number gross_total original_total balance_inventory nuller_datetime null_reason approver_datetime delivered discounted devolution no_inventory).freeze
  store_accessor( *([:extras] + EXTRA_COLUMNS))

  # Extra methods defined for Hstore
  extend Models::HstoreMap
  convert_hstore_to_boolean :devolution, :delivered, :discounted, :no_inventory
  convert_hstore_to_decimal :gross_total, :original_total, :balance_inventory
  convert_hstore_to_timezone :nuller_datetime, :approver_datetime

  # Callbacks
  before_update :check_items_balances
  before_create { |m| m.creator_id = UserSession.id }

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project
  belongs_to :tax

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
      self.due_date ||= Date.today
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
    details.any? {|v| v.quantity != v.balance }
  end

  def details;
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

  alias_method :old_attributes, :attributes
  def attributes
    old_attributes.merge(
      Hash[ EXTRA_COLUMNS.map { |k| [k.to_s, self.send(k)] } ]
    )
  end

  private

    def nulling_valid?
      ['paid', 'approved'].include?(state_was) && is_nulled?
    end

    # Do not allow items to be destroyed if the quantity != balance
    def check_items_balances
      res = true
      details.select(&:marked_for_destruction?).each do |det|
        unless det.quantity === det.balance
          det.errors.add(:quantity, I18n.t('errors.messages.trasaction_details.not_destroy'))
          det.instance_variable_set(:@marked_for_destruction, false)
          res = false
        end
      end

      res
    end

   def valid_currency_change
     errors.add(:currency, I18n.t('errors.messages.movement.currency_change'))  if currency_changed? && ledgers.any?
   end

   def greater_or_equal_due_date
     errors.add(:due_date, I18n.t('errors.messages.movement.greater_due_date'))  if date && due_date && due_date < date
   end
end
