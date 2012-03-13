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

  def moneybox(ac)
    case 
    when ac.amount < 0
      moneybox_tag "DEBEMOS", "#{ac.currency_symbol} #{ntc ac.amount.abs }"
    when ac.amount > 0
      moneybox_tag "DEBE", "#{ac.currency_symbol} #{ntc ac.amount.abs}"
    end
  end

  def moneybox_tag(label, amt)
    content_tag(:div, :class => 'moneybox fl' ) do
      content_tag(:label, label) + content_tag(:h3, amt )
    end
    #.moneybox.fl
    #  %label #{ presenter.moneybox_label ac} #{ac.currency_symbol}
    #  %h3= ntc -ac.amount
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
