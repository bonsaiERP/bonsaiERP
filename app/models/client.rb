# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Client < Contact

  def self.pendent_incomes
    ids = Account.org.client.select("DISTINCT(accountable_id) AS client_id").where("amount > ?", 0).map(&:client_id)
    Client.where(:id => ids)
  end

  def self.pendent_buys
  end

private
  def set_code
    if code.blank?
      codes = Client.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "C-0001"
    end
  end

end
