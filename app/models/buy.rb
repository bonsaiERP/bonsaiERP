# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Buy < Transaction

  after_initialize :set_ref_number, :if => :new_record?

  STATES = ["draft", "aproved", "paid"]

  belongs_to :supplier, :foreign_key => 'contact_id'


  attr_accessible  :ref_number,  :date,                          :contact_id,
                   :project_id,  :currency_id,                   :currency_exchange_rate,
                   :bill_number, :taxis_ids,                     :description,
                   :transaction_details_attributes

private
  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      refs            = Income.org.order("ref_number DESC").limit(1)
      self.ref_number = refs.any? ? refs.first.ref_number.next : "C-#{Date.today.year}-0001"
    end
  end
end
