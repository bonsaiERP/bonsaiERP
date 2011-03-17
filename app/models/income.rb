# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction

  after_initialize :set_ref_number, :if => :new_record?
  
  # callbacks
  #after_save :set_client, :if => :aproving?


  belongs_to :client

  #relationships

  attr_accessible  :ref_number,  :date,                          :contact_id,
                   :project_id,  :currency_id,                   :currency_exchange_rate,
                   :discount,    :bill_number,                   :taxis_ids,
                   :description, :transaction_details_attributes

  

  #accepts_nested_attributes_for :transaction_details, :allow_destroy => true
  #validations
  validates_presence_of :date
  validates_length_of   :description,          :within => 0..255
  validates             :ref_number,           :presence => true , :uniqueness => { :scope => :organisation_id, :allow_blank => false}
  validate              :valid_number_of_items

  

  def draft?
    state == 'draft'
  end

  attr_reader :approving
  def approve!
    unless state == "draft"
      false
    else
      @approving = true
      self.state = "approved"
      self.save(:validate => false)
    end
  end

private
  def aproving?
    aproving
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

  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      refs            = Income.org.order("ref_number DESC").limit(1)
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
