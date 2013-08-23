# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movement < Account

  # module for setters and getters
  extend SettersGetters

  before_update :check_items_balances

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_one :transaction, foreign_key: :account_id, autosave:true
  has_many :transaction_histories, foreign_key: :account_id
  has_many :ledgers, foreign_key: :account_id, class_name: 'AccountLedger'
  has_many :inventories, foreign_key: :account_id

  STATES = %w(draft approved paid nulled)
  ########################################
  # Validations
  validates_presence_of :date, :contact, :contact_id
  validates :state, presence: true, inclusion: {in: STATES}

  ########################################
  # Delegations
  delegate(*create_accessors(*Transaction.transaction_columns), to: :transaction)
  delegate :discounted?, :delivered?, :devolution?, :total_was,
    :creator, :approver, :nuller, :no_inventory?, to: :transaction
  delegate :attributes, to: :transaction, prefix: true

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

  def set_state_by_balance!
    if balance <= 0
      self.state = 'paid'
    elsif balance != total
      self.state = 'approved'
    elsif state.blank?
      self.state = 'draft'
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
      self.due_date = Date.today
    end
  end

  def null!
    if can_null?
      update_attributes(state: 'nulled', nuller_id: UserSession.id, nuller_datetime: Time.zone.now)
    end
  end

  def can_null?
    total === amount && !is_nulled? && ledgers.pendent.empty? && !is_draft?
  end

  alias :old_attributes :attributes
  def attributes
    old_attributes.merge(transaction.attributes)
  end


  def can_pay?
    !is_nulled? && !is_paid?
  end

  def can_devolution?
    !is_draft? && !is_nulled? && total > balance
  end

  def is_active?
    is_approved? || is_paid?
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
end
