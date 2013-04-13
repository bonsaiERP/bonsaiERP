# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Account

  # module for setters and getters
  extend SettersGetters

  include Models::IncomeExpense
  ########################################
  # Callbacks
  before_save :set_client_and_incomes_status

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_one :transaction, foreign_key: :account_id, autosave: true

  has_many :income_details, foreign_key: :account_id, dependent: :destroy, order: 'id asc'
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
  scope :active,   -> { where(state: ['approved', 'paid']) }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :to_pay_contact, -> (cid) { contact.where(amount.gt 0) }
  scope :pendent_except, ->(iid) { active.where{ (id.not_eq iid) & (amount.not_eq 0) } }
  scope :pendent_contact_except, ->(cid, iid) { contact(cid).pendent_except(iid) }

  ########################################
  # Delegations
  delegate *create_accessors(*Transaction.transaction_columns), to: :transaction
  delegate :discounted?, :delivered?, :devolution?, :total_was,
    :creator, :approver, :nuller, to: :transaction
  delegate :attributes, to: :transaction, prefix: true
  delegate :currency, :name, prefix: :org, to: OrganisationSession, allow_nil: true

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

  def subtotal
    self.income_details.inject(0) {|sum, det| sum += det.total }
  end

private
  def set_client_and_incomes_status
    if contact.present?
      contact.client = true unless contact.client?

      set_contact_incomes_status if amount_changed? && !is_draft?

      contact.save if contact.changed?
    end
  end

  def set_contact_incomes_status
    h = ContactBalanceStatus.new(pendent_contact_incomes).create_balances
    h['TOTAL'] = h['TOTAL'] + (amount - amount_was) * exchange_rate
    h[currency] = (h[currency] || 0.0) + amount - amount_was
    contact.incomes_status = h
  end

  def pendent_contact_incomes
    Income.active.pendent_contact_except(contact_id, id)
    .select('sum(amount * exchange_rate) AS tot, sum(amount) AS tot_cur, currency')
    .group(:currency)
  end
end
