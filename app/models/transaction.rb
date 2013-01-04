# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base

  STATES   = %w(draft approved paid due inventory nulled discount)

  DECIMALS = 2
  # Determines if the oprations is made on transaction or pay_plan or payment
  TYPES    = %w(Income Buys)

  ########################################
  # Callbacks
  before_destroy    :null_transaction

  ########################################
  # Relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project

  has_many :inventory_operations

  has_many :account_ledgers

  has_many :transaction_details, dependent: :destroy
  accepts_nested_attributes_for :transaction_details, allow_destroy: true

  # History
  has_many :transaction_histories, autosave: true, dependent: :destroy

  has_many :user_changes, as: :user_changeable, autosave: true

  ########################################
  # Validations
  validates_presence_of :date, :currency, :currency_id, :contact_id, :contact
  validates_presence_of :project, :project_id, :if => "project_id.present?"

  ########################################
  # Scopes
  scope :draft    , where(state: 'draft')
  scope :approved , where(state: 'approved')
  scope :paid     , where(state: 'paid')
  scope :due      , where("transactions.state = ? AND transactions.payment_date < ?" , 'approved' , Date.today)
  scope :inventory, where("transactions.deliver = ? AND transactions.delivered = ?", true, false)
  # Especial used to update
  scope :for_deliver, paid.where("transactions.deliver = ? AND transactions.delivered = ?", false, false)
  scope :nulled, where(:state => 'nulled')

  ########################################
  # Delegates
  delegate :name, :symbol, :plural, :code, to: :currency, prefix: true
  delegate :matchcode, :account_cur, to: :contact, prefix: true, allow_nil: true

  ########################################
  # Methods

  # Define boolean methods for states
  STATES.each do |state|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{state}?
        "#{state}" == state ? true : false
      end
    CODE
  end

  def self.all_states
    STATES + ["awaiting_payment"]
  end

  # Finds using the state
  def self.find_with_state(state)
    ret   = self.includes(:contact, :currency)
    ret = ret.send(scoped_state(state)) if scoped_state(state)
    ret
  end

  # Fins with state
  def self.scoped_state(state)
    state = 'all' unless all_states.include?(state)

    case state
    when 'all' then false
    when 'awaiting_payment' then 'approved'
    else state
    end
  end

  # Define methods for the types of transactions
  TYPES.each do |type|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{type.downcase}?
        "#{type}" == type
      end
    CODE
  end

  # clones a transaction for new record
  def clone_transaction
    if self.is_a?(Income)
      t = Income.new( attributes )
    else
      t = Buy.new( attributes )
    end

    item_prices = Models::Transaction::TransactionDetails.new(self).item_prices

    transaction_details.each do |det|
      t.transaction_details.build(
        item_id: det.item_id,
        quantity: det.quantity, 
        price: det.price
      ) {|d|
        d.original_price = item_prices[det.item_id]
      }
    end

    t.gross_total = gross_total
    t.tax_percent = tax_percent
    t.ref_number = t.get_ref_number

    t = set_clone_buy(t) if t.is_a?(Buy)
    
    t
  end

  # Finds the related account with currency for a Contact
  def account
    contact.account_cur(currency_id)
  end

  # Returns the real state based on state and checked payment_date
  def real_state
    if state == "approved" and !payment_date.blank? and payment_date < Date.today
      "due"
    else
      state
    end
  end

  def subtotal
    self.transaction_details.inject(0) {|sum, v| sum += v.total }
  end

private

  def set_state
    if balance.to_f <= 0
      self.state = "paid"
    elsif state == 'paid' and balance > 0
      self.state = 'approved'
    elsif state.blank?
      self.state = "draft"
    end
  end

  def aproving?
    aproving
  end

  def set_creator
    self.creator_id = UserSession.user_id
  end

end
