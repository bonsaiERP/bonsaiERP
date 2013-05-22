# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::Query
  attr_reader :rel

  def initialize(relation)
    @rel = relation
  end

  def pendent_group_by_contact(relation = rel)
    relation.active.pendent
    .select('sum(amount * exchange_rate) AS tot, sum(amount) AS tot_cur, currency, contact_id')
    .group(:currency, :contact_id).order(:contact_id)
  end

  def pendent_contact_balances(contact_id)
    rel.pendent.contact(contact_id)
    .select('sum(amount * exchange_rate) AS tot, sum(amount) AS tot_cur, currency')
    .group(:currency)
  end

  def joined(sel = join_select)
    rel.select(sel).joins{transaction}.joins{contact}
  end

private
  def join_select
    <<-SQL
    accounts.id, name, amount, state, currency, date, exchange_rate, description,
    transactions.due_date AS ddate, transactions.total as tot,
    contacts.matchcode as cont
    SQL
  end
end
