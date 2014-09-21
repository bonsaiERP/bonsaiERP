# encoding: utf-8
class Report
  attr_reader :date_range, :attrs

  def initialize(drange, attrs = {})
    @date_range = drange
    @attrs = attrs
  end

  def expenses_by_item
    conn.select_rows(sum_movement_details_sql(params(type: 'Expense') ) )
    .map {|v| ItemTransReport.new(*v)}
  end

  def incomes_by_item
    conn.select_rows(sum_movement_details_sql(params(type: 'Income') ) )
    .map {|v| ItemTransReport.new(*v)}
  end

  def total_expenses
    @total_expenses ||= begin
      tot = Expense.active.where(date: date_range.range)
      tot = tot.all_tags(*attrs[:tag_ids])  if any_tags?
      tot.sum('(accounts.total - accounts.amount) * accounts.exchange_rate')
    end
  end

  def total_incomes
    @total_incomes ||= begin
      tot = Income.active.where(date: date_range.range)
      tot = tot.all_tags(*attrs[:tag_ids])  if any_tags?
      tot.sum('(accounts.total - accounts.amount) * accounts.exchange_rate')
    end
  end

  def incomes_dayli
    data = params(type: 'Income')
    @incomes_dayli ||= conn.select_rows(dayli_sql(data)).map {|v| DayliReport.new(*v)}
  end

  def expenses_dayli
    data = params(type: 'Expense')
    @expenses_dayli ||= conn.select_rows(dayli_sql(data)).map {|v| DayliReport.new(*v)}
  end

  def expenses_pecentage
    @expenses_pecentage ||= 100 * (total_expenses / total)
  end

  def incomes_percentage
    @incomes_pecentage ||= 100 * (total_incomes / total)
  end

  def total
    @total ||= total_incomes + total_expenses
  end

  def contacts_incomes
    @contacts_incomes ||= conn.select_rows(contacts_sql params(type: 'Income')).map {|v| ContactReport.new(*v)}
  end

  def contacts_expenses
    @contacts_expenses ||= conn.select_rows(contacts_sql params(type: 'Expense')).map {|v| ContactReport.new(*v)}
  end

private
  def offset
    @offset ||= attrs[:offset].to_i >= 0 ? attrs[:offset].to_i : 0
  end

  def limit
    @limit ||= attrs[:limit].to_i > 0 ? attrs[:limit].to_i : 10
  end

  def params(extra = {})
   ReportParams.new({offset: offset, limit: limit}.merge(extra))
  end

  def sum_movement_details_sql(data)
    <<-SQL
      SELECT i.id, i.name, SUM(d.price * d.quantity * a.exchange_rate) AS total
      FROM movement_details d JOIN items i ON (i.id = d.item_id)
      JOIN accounts a ON (a.id = d.account_id)
      WHERE a.type = '#{data.type}'
      AND a.state IN ('approved', 'paid')
      AND a.date BETWEEN '#{date_range.date_start}' AND '#{date_range.date_end}'
      #{ tags_sql('i') }
      GROUP BY (i.id)
      ORDER BY total DESC
      OFFSET #{data.offset} LIMIT #{data.limit}
    SQL
  end

  def tags_sql(table)
    if any_tags?
      sanitize_sql_array ["AND #{table}.tag_ids @> ARRAY[?]", tag_ids]
    else
      ""
    end
  end

  def dayli_sql(data)
    <<-SQL
      SELECT SUM((a.total - a.amount) * a.exchange_rate) AS tot, a.date
      FROM accounts a
      WHERE a.type = '#{data.type}' and a.state IN ('approved', 'paid')
      AND a.date BETWEEN '#{date_range.date_start}' AND '#{date_range.date_end}'
      GROUP BY a.date
      ORDER BY a.date
    SQL
  end

  def contacts_sql(data)
    <<-SQL
    SELECT c.matchcode, SUM((a.total - a.amount) * a.exchange_rate) AS tot
    FROM contacts c JOIN accounts a ON (a.contact_id=c.id and a.type='#{data.type}')
    WHERE a.date BETWEEN '#{ date_range.date_start }' AND '#{ date_range.date_end }'
    GROUP BY c.id
    ORDER BY tot DESC OFFSET #{data.offset} LIMIT #{data.limit}
    SQL
  end

  def any_tags?
    tag_ids.is_a?(Array) && tag_ids.any?
  end

  def sanitize_sql_array(ary)
    ActiveRecord::Base.send :sanitize_sql_array, ary
  end

  def tag_ids
    attrs[:tag_ids]
  end

  def conn
    ActiveRecord::Base.connection
  end

end

class ReportParams < OpenStruct; end

class ItemTransReport < Struct.new(:id, :name, :tot)
  def total
    tot.to_f
  end
end

class ContactReport < Struct.new(:contact, :tot)
  def to_s
    contact
  end

  def total
    tot.to_f
  end
end

class DayliReport < Struct.new(:tot, :date)
  def total
    tot.to_f
  end
end
