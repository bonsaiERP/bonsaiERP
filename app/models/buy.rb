# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Buy < Transaction

  after_initialize :set_ref_number, :if => :new_record?

  belongs_to :supplier, :foreign_key => 'contact_id'


  attr_accessible  :ref_number,  :date,                          :contact_id,
                   :project_id,  :currency_id,                   :exchange_rate,
                   :bill_number, :taxis_ids,                     :description,
                   :transaction_details_attributes

  #validations
  validates             :ref_number,           :presence => true , :uniqueness => { :scope => :organisation_id, :allow_blank => false}
  validate              :valid_number_of_items

  def to_s
    "Compra #{ref_number}"
  end

  def get_ref_number
    refs            = Buy.org.order("ref_number DESC").limit(1)
    refs.any? ? refs.first.ref_number.next : "C-#{Date.today.year}-0001"

  end

private
  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      self.ref_number = get_ref_number
    end
  end
end
