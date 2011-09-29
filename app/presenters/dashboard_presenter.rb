# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardPresenter < ApplicationPresenter

  def accounts_to_recieve
    tot_accounts = Account.org.to_recieve.group(:currency_id).sum(:amount)
    tot_incomes  = Income.org.approved.group(:currency_id).sum(:balance)
    keys = (tot_accounts.keys + tot_incomes.keys).uniq
  
    keys.map do |cur_id|
      s = tot_accounts[cur_id].to_f.abs + tot_incomes[cur_id].to_f
      "#{currencies[cur_id]} #{s}"
    end
  end

  def accounts_to_pay
    tot_accounts = Account.org.to_pay.group(:currency_id).sum(:amount)
    tot_incomes  = Buy.org.approved.group(:currency_id).sum(:balance)
    keys = (tot_accounts.keys + tot_incomes.keys).uniq
  
    keys.map do |cur_id|
      s = tot_accounts[cur_id].to_f.abs + tot_incomes[cur_id].to_f
      "#{currencies[cur_id]} #{s}"
    end
  end

  def pendent_conciliations
    h.link_to "Ver todas", "/todas"
  end

  def currencies
    @currencies ||= Hash[Currency.scoped[:id, :symbol] ]
  end
end
