# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Account

  ########################################
  # Callbacks
  before_create :set_client

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_one :transaction, foreign_key: :account_id, autosave:true

  has_many :income_details, foreign_key: :account_id, dependent: :destroy
  accepts_nested_attributes_for :income_details, allow_destroy: true,
    reject_if: proc {|det| det.fetch(:item_id).blank? }

  has_many :payments, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: 'payin'}
  has_many :transaction_histories, foreign_key: :account_id

  STATES = %w(draft approved paid)
  ########################################
  # Validations
  validates_presence_of :date, :contact, :contact_id
  validates :state, presence: true, inclusion: {in: STATES}

  ########################################
  # Scopes
  scope :discount, where(discounted: true)

  ########################################
  # Delegations
  TRANSACTION_METHODS = [
    :balance, :bill_number, :gross_total, :original_total, :balance_inventory, 
    :payment_date, :creator_id, :creator, :approver_id, 
    :approver, :nuller_id, :nuller,
    :null_reason, :approver_datetime, 
    :delivered, :discounted, :devolution
  ].freeze
  delegate *getters_setters_array(*TRANSACTION_METHODS), to: :transaction
  delegate :discounted?, :delivered?, :devolution?, :approve!, to: :transaction
  delegate :attributes, to: :transaction, prefix: true

  # Define boolean methods for states
  STATES.each do |state|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{state}?
        "#{state}" == state ? true : false
      end
    CODE
  end

  def self.new_income(attrs={})
    self.new do |i|
      i.build_transaction
      i.attributes = attrs
      i.state ||= 'draft'
    end
  end

  ########################################
  # Aliases, alias and alias_method not working
  [[:ref_number, :name], [:total, :amount]].each do |meth|
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
    else
      self.state = 'draft'
    end
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
    unless is_approved?
      self.state = 'approved'
      self.approver_id = UserSession.id
      self.approver_datetime = Time.zone.now
      self.payment_date = Date.today
    end
  end

private
  def set_client
    contact.update_attribute(:client, true) if contact.present? && !contact.client?
  end
end
