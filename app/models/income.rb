# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction
  acts_as_org
  
  # callbacks
  before_create :set_state

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
    case I18n.locale
    when :es
      ["Borrador", "Aprobado", "Pagado"]
    end    
  end

  def aproved?
    self.state != "draft"
  end

private
  def set_state
    self.state = STATES.first
  end
end
