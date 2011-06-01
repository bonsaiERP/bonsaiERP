# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Client < Contact

  ACCOUNT_NUMBER = "client"

  before_destroy :check_client_for_delete

private
  def set_code
    if code.blank?
      codes = Client.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "C-0001"
    end
  end

  # Checks the contact before delete
  def check_client_for_delete
    if Transaction.org.where(:contact_id => id).any? or AccountLedger.where(:contact_id => id).any?
      self.errors[:base] << "No es posible borrar, el cliente esta relacionado"
      false
    else
      true
    end
  end
end
