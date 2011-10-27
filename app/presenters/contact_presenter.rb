# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactPresenter < BasePresenter
  presents :contact

  def incomes
    contact.incomes.approved.group(:currency_id).sum(:balance).map do |cur, amt|
      [currencies[cur], amt]
    end
  end

  def buys
    contact.buys.approved.group(:currency_id).sum(:balance).map do |cur, amt|
      [currencies[cur], amt]
    end
  end

  def label
    case contact.class.to_s
    when "Client"
      "Cliente"
    when "Supplier"
      "Proveedor"
    when "Staff"
      "Personal"
    end
  end

end
