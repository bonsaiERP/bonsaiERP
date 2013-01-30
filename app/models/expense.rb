# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Account

  # module for setters and getters
  extend SettersGetters

  ########################################
  # Callbacks
  before_create :set_supplier

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :project

  has_one :transaction, foreign_key: :account_id, autosave:true

  has_many :expense_details, foreign_key: :account_id, dependent: :destroy
  accepts_nested_attributes_for :expense_details, allow_destroy: true,
    reject_if: proc {|det| det.fetch(:item_id).blank? }

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
  delegate *create_accessors(*Transaction.transaction_columns), to: :transaction
  delegate :discounted?, :delivered?, :devolution?, to: :transaction
  delegate :attributes, to: :transaction, prefix: true

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
      e.state ||= 'draft'
      yield e if block_given?
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
    year= Date.today.year.to_s[2..4]

    if ref.present?
      _, y, num = ref.split('-')
      if y == year
        "E-#{y}-#{num.next}"
      else
        "E-#{year}-0001"
      end
    else
      "E-#{year}-0001"
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
    self.expense_details.inject(0) {|sum, det| sum += det.total }
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
      self.due_date = Date.today
    end
  end

private
  def set_supplier
   contact.update_attribute(:supplier, true) if contact.present? && !contact.supplier?
  end
end
