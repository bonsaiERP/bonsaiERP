# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Account
  validates :ref_number, :presence => true , :uniqueness => true

  def self.get_ref_number
    ref = Expense.order("ref_number DESC").first
    ref.present? ? ref.ref_number.next : "E-0001"
  end

  ########################################
  # Callbacks
  before_create :set_supplier

  def to_s
    "Egreso #{ref_number}"
  end

private
  def set_supplier
   contact.update_attribute(:supplier, true) if contact.present? && !contact.supplier?
  end
end
