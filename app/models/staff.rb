# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Staff < Contact
  before_destroy :check_staff_for_delete

  attr_accessible :position

  validates_presence_of :position

private
  def set_code
    if code.blank?
      codes = Client.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "C-0001"
    end
  end

  # Checks the contact before delete
  def check_staff_for_delete
    false
    #if Transaction.org.where(:contact_id => id).any? or AccountLedger.where(:contact_id => id).any?
    #  self.errors[:base] << "No es posible borrar, el cliente esta relacionado"
    #  false
    #else
    #  true
    #end
  end
end

