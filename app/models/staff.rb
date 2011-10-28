# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Staff < Contact

  attr_accessible :position

  validates_presence_of :position, :first_name, :last_name

  def self.pendent
    ac_ids = Account.org.staff.select("DISTINCT(accountable_id) AS staff_id").where("amount > ?", 0).map(&:staff_id)
    Client.where(:id => ac_ids)
  end

  def self.debt
    ac_ids = Account.org.staff.select("DISTINCT(accountable_id) AS staff_id").where("amount < ?", 0).map(&:staff_id)
    Client.where(:id => ac_ids)
  end

private
  def set_code
    if code.blank?
      codes = Staff.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "PER-0001"
    end
  end

end

