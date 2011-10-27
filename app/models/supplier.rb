# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Supplier < Contact

  def self.pendent
    ac_ids = Account.org.supplier.select("DISTINCT(accountable_id) AS supplier_id").where("amount > ?", 0).map(&:supplier_id)
    in_ids = Income.org.approved.select("DISTINCT(contact_id) AS supplier_id").map(&:supplier_id)
    ids = ac_ids + in_ids
    Supplier.where(:id => ids.uniq)
  end

  def self.debt
    ac_ids = Account.org.supplier.select("DISTINCT(accountable_id) AS supplier_id").where("amount < ?", 0).map(&:supplier_id)
    in_ids = Buy.org.approved.select("DISTINCT(contact_id) AS supplier_id").map(&:supplier_id)
    ids = ac_ids + in_ids
    Supplier.where(:id => ids.uniq)
  end

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
