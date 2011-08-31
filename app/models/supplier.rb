# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Supplier < Contact

  private
  def set_code
    if code.blank?
      codes = Supplier.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "P-0001"
    end
  end

  # Checks the user before delete
  def check_supplier_for_delete
    if Transaction.org.where(:contact_id => id).any? or AccountLedger.where(:contact_id => id).any?
      self.errors[:base] << "No es posible borrar, el proveedor esta relacionado"
      false
    else
      true
    end
  end
end
