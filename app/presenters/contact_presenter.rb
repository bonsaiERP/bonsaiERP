# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactPresenter < ApplicationPresenter

  def initialize(cont)
    @contact = cont
  end

  def incomes
    @contact.incomes.approved.group(:currency_id).sum(:balance).map do |cur, amt|
      [currencies[cur], amt]
    end
  end

  def buys
    @contact.buys.approved.group(:currency_id).sum(:balance).map do |cur, amt|
      [currencies[cur], amt]
    end
  end

end
