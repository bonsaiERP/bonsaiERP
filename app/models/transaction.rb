# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  acts_as_org

  STATES   = ["draft"  , "approved" , "paid" , "due", "inventory", "nulled"]
  TYPES    = ['Income' , 'Expense'  , 'Buy']
  DECIMALS = 2
  # Determines if the oprations is made on transaction or pay_plan or payment
  ###############################
  include Models::Transaction::Calculations
  include Models::Transaction::Trans
  include Models::Transaction::Approve
  include Models::Transaction::PayPlan
  include Models::Transaction::Payment

  ###############################
 
  # callbacks
  before_validation :set_defaults, :if => :new_record?
  before_create     :set_creator
  before_destroy    :null_transaction
  #before_save       :set_state

  # relationships
  #belongs_to :account
  belongs_to :contact
  belongs_to :currency
  belongs_to :project
  belongs_to :creator , :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :creditor, :class_name => "User"
  belongs_to :nuller,   :class_name => "User"

  #has_one  :account_ledger, :conditions => "operation = 'transaction'"

  has_many :pay_plans          , :dependent => :destroy , :order => "payment_date ASC", :autosave => true
  has_many :transaction_details, :dependent => :destroy
  has_many :account_ledgers    , :dependent => :destroy, :conditions => "operation != 'transaction'", :autosave => false
  has_many :inventory_operations

  has_and_belongs_to_many :taxes, :class_name => 'Tax'
  # nested attributes
  accepts_nested_attributes_for :transaction_details, :allow_destroy => true

  # validations
  #validates :account_id, :contact_account => true
  validates :contact_id, :contact  => true

  #default_scope where(:active => true)

  # scopes
  scope :draft    , where(:state => 'draft')
  scope :approved , where(:state => 'approved')
  scope :paid     , where(:state => 'paid')
  scope :due      , where("transactions.state = ? AND transactions.payment_date < ?" , 'approved' , Date.today)
  scope :inventory, where("transactions.deliver = ? AND transactions.delivered = ?", true, false)
  scope :credit   , where(:cash => false)
  # Especial used to update
  scope :for_deliver, paid.where("transactions.deliver = ? AND transactions.delivered = ?", false, false)
  scope :nulled, where(:state => 'nulled')

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
    ret   = self.org.includes(:contact, :currency).order("created_at DESC")
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
    ret = self.org.includes(:contact, :currency)
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

  # clones a transaction for new record
  def clone_transaction
    if self.is_a?(Income)
      t = Income.new( attributes )
    else
      t = Buy.new( attributes )
    end

    t.transaction_details_attributes = transaction_details.map do |det|
      h = det.attributes
      h["id"] = nil
      h["transaction_id"] = nil
      h
    end
    t.taxis_ids = self.taxis_ids
    t.gross_total = gross_total
    t.tax_percent = tax_percent
    t.ref_number = t.get_ref_number
    
    t
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

  def credit?
    not(cash)
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

  # Finds the related account with currency for a Contact
  def account
    contact.accounts.where(:currency_id => currency_id).first
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
      ["Proforma" , "Aprobado" , "Pagado" , "Vencido", "Pendiente", "Anulado"]
    when :en
      ["Draft"    , "Aproved"  , "Paid"   , "Due", "Pendent", "Nulled"]
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

  # Presents the currency symbol name if not default currency
  def present_currency
    unless Organisation.find(OrganisationSession.organisation_id).id == self.currency_id
      self.currency.to_s
    end
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

  def null_transaction
    self.active          = false
    self.state           = "nulled"
    self.nuller_id       = UserSession.user_id
    self.nuller_datetime = Time.zone.now
    self.save
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
    self.exchange_rate ||= 1
    self.currency_id ||= OrganisationSession.currency_id
    self.gross_total ||= 0
    self.total ||= 0
    self.date ||= Date.today
    @trans = true
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
