# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Account
  ########################################
  # Callbacks
  before_create :set_supplier

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_one :transaction, foreign_key: :account_id, autosave:true
  has_many :expense_details, foreign_key: :account_id, dependent: :destroy
  accepts_nested_attributes_for :expense_details, allow_destroy: true

  STATES = %w(draft approved paid)
  ########################################
  # Validations
  validates_presence_of :date
  validates :state, presence: true, inclusion: {in: STATES}

  ########################################
  # Scopes
  scope :discount, where(discounted: true)

  ########################################
  # Delegations
  TRANSACTION_METHODS = [
    :balance, :bill_number, :discount, :gross_total, :original_total,
    :balance_inventory, :payment_date, :creator_id, :approver_id, :nuller_id,
    :null_reason, :approver_datetime, :delivered, :discount, :devolution
  ].freeze
  delegate *getters_setters_array(*TRANSACTION_METHODS), to: :transaction

  # Define boolean methods for states
  STATES.each do |state|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{state}?
        "#{state}" == state ? true : false
      end
    CODE
  end

  def self.new_expense(attrs={})
    self.new do |e|
      e.build_transaction
      e.attributes = attrs
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
    ref = Expense.order("name DESC").limit(1).pluck(:name).first
    ref.present? ? ref.next : "I-0001"
  end

  def set_state_by_balance!
    if balance == 0
      self.state = 'paid'
    elsif balance < total
      self.state = 'approved'
    else
      self.state = 'draft'
    end
  end

  def subtotal
    self.expense_details.inject(0) {|sum, v| sum += v.total }
  end

private
  def set_supplier
   contact.update_attribute(:supplier, true) if contact.present? && !contact.supplier?
  end
end
