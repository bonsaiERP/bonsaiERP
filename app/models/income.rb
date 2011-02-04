# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction
  acts_as_org
  
  # callbacks
  before_save :set_state

  STATES = ["draft", "aproved", "payed"]


  attr_accessible :ref_number, :date, :contact_id,
                  :project_id, :currency_id, :currency_exchange_rate,
                  :discount, :bill_number, :taxis_ids,
                  :description, :transaction_details_attributes


  #accepts_nested_attributes_for :transaction_details, :allow_destroy => true
  #validations
  validates_presence_of :ref_number, :date

  # Presents a localized name for state
  def show_state
    @hash ||= create_states_hash
    @hash[state]
  end

  def show_pay_plans?
    if state == "draft"
      true
    elsif state == "aproved" and !cash
      true
    else
      false
    end
  end

  def show_payments?
    state != 'draft'
  end

  def draft?
    state == 'draft'
  end

  def aprove!
    if state != "draft"
      false
    else
      self.state = "aproved"
      self.save
    end
  end

private
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
      ["Borrador", "Aprobado", "Pagado"]
    when :en
      ["Draft", "Aproved", "Paid"]
    when :pt
      ["Borracha", "Aprovado", "Pagado"]
    end
    Hash[STATES.zip(arr)]
  end

end
