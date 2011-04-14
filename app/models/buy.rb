# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Buy < Transaction

  after_initialize :set_ref_number, :if => :new_record?

  belongs_to :supplier, :foreign_key => 'contact_id'


  attr_accessible  :ref_number,  :date,                          :contact_id,
                   :project_id,  :currency_id,                   :currency_exchange_rate,
                   :bill_number, :taxis_ids,                     :description,
                   :transaction_details_attributes

  #validations
  #validates_length_of   :description,          :within => 0..255
  validates_presence_of :date, :contact_id
  validates             :ref_number,           :presence => true , :uniqueness => { :scope => :organisation_id, :allow_blank => false}
  validate              :valid_number_of_items

  def to_s
    "Compra #{ref_number}"
  end

private
  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      refs            = Income.org.order("ref_number DESC").limit(1)
      self.ref_number = refs.any? ? refs.first.ref_number.next : "C-#{Date.today.year}-0001"
    end
  end
end
