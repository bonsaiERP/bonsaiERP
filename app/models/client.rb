# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Client < Contact

  def self.pendent
    ac_ids = Account.org.client.select("DISTINCT(accountable_id) AS client_id").where("amount > ?", 0).map(&:client_id)
    in_ids = Income.org.approved.select("DISTINCT(contact_id) AS client_id").map(&:client_id)
    ids = ac_ids + in_ids
    Client.where(:id => ids.uniq)
  end

  def self.debt
    ac_ids = Account.org.client.select("DISTINCT(accountable_id) AS client_id").where("amount < ?", 0).map(&:client_id)
    in_ids = Buy.org.approved.select("DISTINCT(contact_id) AS client_id").map(&:client_id)
    ids = ac_ids + in_ids
    Client.where(:id => ids.uniq)
  end

private
  def set_code
    if code.blank?
      codes = Client.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "C-0001"
    end
  end

end
