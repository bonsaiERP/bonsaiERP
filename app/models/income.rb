# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Account

  # module for setters and getters
  extend SettersGetters
  ########################################
  # Callbacks
  before_create :set_client

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_one :transaction, foreign_key: :account_id, autosave: true

  has_many :income_details, foreign_key: :account_id, dependent: :destroy
  accepts_nested_attributes_for :income_details, allow_destroy: true,
    reject_if: proc {|det| det.fetch(:item_id).blank? }

  has_many :payments, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: 'payin'}
  has_many :payments_devolutions, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: ['payin', 'devin']}
  has_many :interests, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: 'intin'}

  has_many :transaction_histories, foreign_key: :account_id

  STATES = %w(draft approved paid)
  ########################################
  # Validations
  validates_presence_of :date, :contact, :contact_id
  validates :state, presence: true, inclusion: {in: STATES}

  ########################################
  # Scopes
  scope :discount, joins(:transaction).where(transaction: {discounted: true})
  scope :approved, -> { where(state: 'approved') }

  ########################################
  # Delegations
  delegate *create_accessors(*Transaction.transaction_columns), to: :transaction
  delegate :discounted?, :delivered?, :devolution?, :total_was,
    :creator, :approver, :nuller, to: :transaction
  delegate :attributes, to: :transaction, prefix: true

  # Define boolean methods for states
  STATES.each do |_state|
    define_method :"is_#{_state}?" do
      _state == state
    end
  end

  def self.new_income(attrs={})
    self.new do |i|
      i.build_transaction
      i.attributes = attrs
      i.state ||= 'draft'
      yield i if block_given?
    end
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

  def self.get_ref_number
    ref = Income.order("name DESC").limit(1).pluck(:name).first
    year= Date.today.year.to_s[2..4]

    if ref.present?
      _, y, num = ref.split('-')
      if y == year
        "I-#{y}-#{num.next}"
      else
        "I-#{year}-0001"
      end
    else
      "I-#{year}-0001"
    end
  end

  def set_state_by_balance!
    if balance <= 0
      approve!
      self.state = 'paid'
    elsif balance < total
      approve!
      self.state = 'approved' if self.is_paid?
    else
      self.state = 'draft' if state.blank?
    end
  #binding.pry
  end

  def subtotal
    self.income_details.inject(0) {|sum, det| sum += det.total }
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

private
  def set_client
    contact.update_attribute(:client, true) if contact.present? && !contact.client?
  end
end
