# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  acts_as_org

  STATES   = ["draft"  , "approved" , "paid" , "due", "inventory"]
  TYPES    = ['Income' , 'Expense'  , 'Buy']
  DECIMALS = 2
  # Determines if the oprations is made on transaction or pay_plan or payment
  ###############################
  # Methods for pay_plans
  include Models::Transaction::PayPlans

  include Models::Transaction::Trans
  ###############################
 
  attr_reader :trans, :approving
  # callbacks
  before_validation :set_defaults, :if => :new_record?
  before_create :set_creator
  #after_initialize :set_trans_to_true
  #before_save       :update_payment_date
  before_save       :set_state

  #after_update      :update_transaction_pay_plans, :if => :trans?

  # relationships
  belongs_to :account
  belongs_to :currency
  belongs_to :project
  belongs_to :creator , :class_name => "User"
  belongs_to :approver, :class_name => "User"

  has_many :pay_plans          , :dependent => :destroy , :order => "payment_date ASC"
  has_many :payments           , :dependent => :destroy
  has_many :transaction_details, :dependent => :destroy

  has_and_belongs_to_many :taxes, :class_name => 'Tax'
  # nested attributes
  accepts_nested_attributes_for :transaction_details, :allow_destroy => true

  # scopes
  scope :draft    , where(:state => 'draft')
  scope :approved , where(:state => 'approved')
  scope :paid     , where(:state => 'paid')
  scope :due      , where("transactions.state = ? AND transactions.payment_date < ?" , 'approved' , Date.today)
  scope :inventory, where("balance_inventory > 0 AND state != 'draft'")
  scope :credit   , where(:cash => false)

  delegate :name, :symbol, :plural, :code, :to => :currency, :prefix => true


  # Define boolean methods for states
  STATES.each do |state|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{state}?
        "#{state}" == state ? true : false
      end
    CODE
  end

  def self.all_states
    STATES + ["awaiting_payment"]
  end

  # Finds using the state
  def self.find_with_state(state)
    ret   = self.org.includes(:contact, :pay_plans, :currency).order("date DESC")
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

  # method used for searching
  def self.search(options)
    ret = self.org.includes(:contact, :pay_plans, :currency)
    ret = ret.send(scoped_state(options[:option])) if scoped_state(options[:option])
    ret.where("transactions.ref_number LIKE :code OR contacts.matchcode LIKE :code", :code => "%#{options[:search]}%")
  end

  # Define methods for the types of transactions
  TYPES.each do |type|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{type.downcase}?
        "#{type}" == type
      end
    CODE
  end

  # Aprove a transaction
  # @param Hash # Hass of prefereces where you can read the user and organisation preferences
  def approve!
    unless state == "draft"
      false
    else
      @approving       = true
      self.state       = "approved"
      self.approver_id = UserSession.user_id
      self.save(:validate => false)
    end
  end

  # Tells if the user can approve a transaction based on the preferences
  def can_approve?(session)
    return false unless draft?
    if User::ROLES.slice(0,2).include?(session[:user][:rol])
      true
    else
      false
    end
  end

  def to_json
    attributes.merge(:currency_symbol => currency_symbol, :real_state => real_state).to_json
  end

  def credit?
    pay_plans.any?
  end

  # downcased type
  def typed
    type.downcase
  end

  # Transalates the type for any language
  def type_translated
    arr = case I18n.locale
      when :es
        ['Venta', 'Gasto', 'Compra']
    end
    Hash[TYPES.zip(arr)][type]
  end

  # Presents a localized name for state
  def show_state
    @hash ||= create_states_hash
    @hash[real_state]
  end

  # Creates a states hash based on the locale
  def create_states_hash
    arr = case I18n.locale
    when :es
      ["Borrador" , "Aprobado" , "Pagado" , "Vencido"]
    when :en
      ["Draft"    , "Aproved"  , "Paid"   , "Due"]
    when :pt
      ["Borracha" , "Aprovado" , "Pagado" , "Vencido"]
    end
    Hash[STATES.zip(arr)]
  end
  # Returns the real state based on state and checked payment_date
  def real_state
    if state == "approved" and !payment_date.blank? and payment_date < Date.today
      "due"
    else
      state
    end
  end

  def show_pay_plans?
    if state == "draft"
      true
    elsif state != "draft" and !cash
      true
    end
  end

  def show_payments?
    state != 'draft'
  end

  def show_pay_plans?
    if draft?
      true
    elsif cash?
      false
    else
      true
    end
  end

  # quantity without discount and taxes
  def subtotal
    self.transaction_details.inject(0) {|sum, v| sum += v.total }
  end

  # Calculates the amount for taxes
  def total_taxes
    (gross_total - total_discount ) * tax_percent/100
  end

  def total_discount
    gross_total * discount/100
  end

  def total_payments
    payments.active.inject(0) {|sum, v| sum += v.amount }
  end

  def total_payments_with_interests
    payments.active.inject(0) {|sum, v| sum += v.amount + v.interests_penalties }
  end

  # Presents the currency symbol name if not default currency
  def present_currency
    unless Organisation.find(OrganisationSession.organisation_id).id == self.currency_id
      self.currency.to_s
    end
  end

  # Presents the total in currency unless the default currency
  def total_currency
    (self.total/self.currency_exchange_rate).round(DECIMALS)
  end

  # Sums the total of payments
  def payments_total
    payments.active.sum(:amount)
  end

  # Sums the total amount of the payments and interests
  def payments_amount_interests_total
    payments.active.sum(:amount) + payments.active.sum(:interests_penalties)
  end

  # Returns the total value of pay plans that haven't been paid'
  def pay_plans_total
    pay_plans.unpaid.sum('amount')
  end

  # Returns the total amount to be paid for unpaid pay_plans
  def pay_plans_balance
    balance - pay_plans_total
  end

  # Updates cash based on the pay_plans
  def update_pay_plans_cash
    self.cash = ( pay_plans.size > 0 )
    self.save
  end

  # Sets a default payment date using PayPlan
  def update_payment_date
    # Do not user PayPlan.unpaid.where(:transaction_id => id).limit(1) 
    # because it can't find a created pay_pland in the middle of a transaction
    pp = pay_plans.unpaid.where(:transaction_id => id).limit(1)

    if pp.any?
      self.payment_date = pp.first.payment_date
    else
      self.payment_date = self.date
    end
  end

  # Prepares a payment with the current notes to pay
  # @param Hash options
  def new_payment(options = {})
    amt = int_pen = 0
    if pay_plans.unpaid.any?
      pp = pay_plans.unpaid.first
      amt, int_pen =  [pp.amount, pp.interests_penalties]
    else
      amt = balance
    end

    options[:amount] = options[:amount] || amt
    options[:interests_penalties] = options[:interests_penalties] || int_pen
    payments.build({:transaction_id => id, :currency_id => currency_id}.merge(options))
  end


  # Adds a payment and updates the balance
  def add_payment(amount)
    if amount > balance
      return false
    else
      @trans = false
      self.balance = (balance - amount)
      self.save
    end
  end

  # Substract the amount from the balance
  def substract_payment(amount)
    @trans = false
    self.balance = (balance + amount)
    self.save
  end

  def real_total
    total / currency_exchange_rate
  end

  def set_trans(value)
    @trans = value
  end

  # Returs the pay_type for the current instance
  def pay_type
    case type
    when "Income" then "cobro"
    when "Buy", "Expense" then "pago"
    end
  end

  # returns the items dependig of what type is the transction
  def get_items
    case type
    when "Income"  then Item.org.income
    when "Buy"     then Item.org.buy
    when "Expense" then Item.org.expense
    end
  end

  def get_type
    @t ||= case type
    when "Income"  then "venta"
    when "Expense" then "gasto"
    when "Buy"     then "compra"
    end
  end

  # Creates the name for the pdf
  def pdf_name
    "#{get_type}-#{ref_number}"
  end

  # Creates the pdf title based on the type
  def pdf_title
    t = get_type

    n = draft? ? "Proforma" : "Nota"
    "#{n} de #{t} #{ref_number}"
  end

  def show_inventory?
    not(draft?)
  end

  # method for new
  def set_defaults_new
    set_defaults
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

  # set default values for discount and taxes
  def set_defaults
    self.cash = cash.nil? ? true : cash
    self.active = active.nil? ? true : active
    self.discount ||= 0
    self.tax_percent = taxes.inject(0) {|sum, t| sum += t.rate }
    self.currency_exchange_rate ||= 1
    self.gross_total ||= 0
    self.total ||= 0
    self.date ||= Date.today
    @trans = true
  end

  def set_trans_to_true
    @trans = true
  end




  # Determines if it is a transaction or other operation
  def trans?
    @trans
  end

  def aproving?
    aproving
  end

  # To have at least one item
  def valid_number_of_items
    self.errors.add(:base, "Debe ingresar seleccionar al menos un ítem") unless self.transaction_details.any?
  end

  def set_creator
    self.creator_id = UserSession.user_id
  end


end
