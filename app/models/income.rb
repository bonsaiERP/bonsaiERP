# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction

  after_initialize :set_ref_number, :if => :new_record?
  
  # callbacks
  before_save :set_state
  after_save :set_client, :if => :aproving?

  STATES = ["draft", "aproved", "paid", "due"]


  #relationships

  attr_accessible :ref_number, :date, :contact_id,
                  :project_id, :currency_id, :currency_exchange_rate,
                  :discount, :bill_number, :taxis_ids,
                  :description, :transaction_details_attributes

  

  #accepts_nested_attributes_for :transaction_details, :allow_destroy => true
  #validations
  validates_presence_of :date
  validates_length_of :description, :within => 0..255
  validates :ref_number, :presence => true ,:uniqueness => {:scope => :organisation_id, :allow_blank => false}
  validate :valid_number_of_items

  # scopes
  scope :draft, where(:state => 'draft')
  scope :aproved, where(:state => 'aproved')
  scope :paid, where(:state => 'paid')
  scope :due, where(["transactions.state = ? AND transactions.payment_date < ?", 'aproved', Date.today])
  scope :credit, where(:cash => false)
  
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
    state = 'all' unless all_states.include?(state)
    ret = Income.org.includes(:contact, :pay_plans, :currency).order("date DESC")
    case state
    when 'all' then ret
    when 'awaiting_payment' then ret.aproved.credit
    else
      ret.send(state)
    end
  end

  # Presents a localized name for state
  def show_state
    @hash ||= create_states_hash
    @hash[real_state]
  end

  # Returns the real state based on state and checked payment_date
  def real_state
    if state == "aproved" and !payment_date.blank? and payment_date < Date.today
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

  def draft?
    state == 'draft'
  end

  attr_reader :aproving
  def aprove!
    if state != "draft"
      false
    else
      @aproving = true
      self.state = "aproved"
      self.save
    end
  end

private
  def aproving?
    aproving
  end

  def set_state
    if balance <= 0
      self.state = "paid"
    elsif state.blank?
      self.state = "draft"
    end
  end

  # Creates a states hash based on the locale
  def create_states_hash
    arr = case I18n.locale
    when :es
      ["Borrador", "Aprobado", "Pagado", "Vencido"]
    when :en
      ["Draft", "Aproved", "Paid", "Due"]
    when :pt
      ["Borracha", "Aprovado", "Pagado", "Vencido"]
    end
    Hash[STATES.zip(arr)]
  end

  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      refs = Income.org.order("ref_number DESC").limit(1)
      self.ref_number = refs.any? ? refs.first.ref_number.next : "V-00001"
    end
  end

  def valid_number_of_items
    self.errors.add(:base, "Debe ingresar seleccionar al menos un ítem") unless self.transaction_details.any?
  end

  def set_client
    contact.update_attribute(:client, true)
  end
end
