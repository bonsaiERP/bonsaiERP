# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::Query
  attr_reader :rel

  def initialize(relation)
    @rel = relation
  end

  def index(params = {})
    self.class.index_includes movement_set(params)
  end

  def search(s)
    @rel.joins(:contact)
    .where("accounts.name ILIKE :s OR accounts.description ILIKE :s OR contacts.matchcode ILIKE :s", s: "%#{ s }%")
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

  private

    def self.index_includes(rel)
      rel.includes(:contact, :tax, :updater, :creator, :approver, :nuller)
    end

    def movement_set(params = {})
      case
      when params[:contact_id].present?
        rel.contact(params[:contact_id])
      when params[:search].present?
        search(params[:search])
      else
        rel
      end
    end

    def join_select
      <<-SQL
      accounts.id, name, amount, state, currency, date, exchange_rate, description,
      transactions.due_date AS ddate, transactions.total as tot,
      contacts.matchcode as cont
      SQL
    end
end
