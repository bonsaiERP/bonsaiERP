# encoding: utf-8
class Report
  attr_reader :date_range, :attrs

  def initialize(drange, attrs = {})
    @date_range = drange
    @attrs = attrs
  end

  def expenses_by_item
    conn.select_rows(sum_transaction_details_sql(params(type: 'Expense') ) )
    .map {|v| ItemTransReport.new(*v)}
  end

  def incomes_by_item
    conn.select_rows(sum_transaction_details_sql(params(type: 'Income') ) )
    .map {|v| ItemTransReport.new(*v)}
  end

  def total_expenses
    @total_expenses ||= begin
      tot = Expense.active.joins(:transaction).where(date: date_range.range)
      tot = tot.all_tags(attrs[:tag_ids])  if any_tags?
      tot.sum('(transactions.total - accounts.amount) * accounts.exchange_rate')
    end
  end

  def total_incomes
    @total_incomes ||= begin
      tot = Income.active.joins(:transaction).where(date: date_range.range)
      tot = tot.all_tags(attrs[:tag_ids])  if any_tags?
      tot.sum('(transactions.total - accounts.amount) * accounts.exchange_rate')
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
    @expenses_pecentage ||= total_expenses / total
  end

  def incomes_percentage
    @incomes_pecentage ||= total_incomes / total
  end

  def total
    @total ||= total_incomes + total_expenses
  end

private
  def any_tags?
    attrs[:tag_ids].is_a?(Array) && attrs[:tag_ids].any?
  end

  def offset
    @offset ||= attrs[:offset].to_i >= 0 ? attrs[:offset].to_i : 0
  end

  def limit
    @limit ||= attrs[:limit].to_i > 0 ? attrs[:limit].to_i : 10
  end

  def params(extra = {})
   ReportParams.new({offset: offset, limit: limit}.merge(extra))
  end

  def conn
    ActiveRecord::Base.connection
  end

  def sum_transaction_details_sql(data)
    <<-SQL
      SELECT i.id, i.name, SUM(d.price * d.quantity * a.exchange_rate) AS total
      FROM transaction_details d JOIN items i ON (i.id = d.item_id)
      JOIN accounts a ON (a.id = d.account_id)
      WHERE a.type = '#{data.type}'
      AND a.state IN ('approved', 'paid')
      AND a.date BETWEEN '#{date_range.date_start}' AND '#{date_range.date_end}'
      GROUP BY (i.id)
      ORDER BY total DESC
      OFFSET #{data.offset} LIMIT #{data.limit}
    SQL
  end

  def dayli_sql(data)
    <<-SQL
      SELECT SUM((t.total - a.amount) * a.exchange_rate) AS tot, a.date
      FROM accounts a JOIN transactions t ON (a.id = t.account_id)
      WHERE a.type = '#{data.type}' and a.state IN ('approved', 'paid')
      AND a.date BETWEEN '#{date_range.date_start}' AND '#{date_range.date_end}'
      GROUP BY a.date
      ORDER BY a.date
    SQL
  end
end

class ReportParams < OpenStruct; end

class ItemTransReport < Struct.new(:id, :name, :tot)
  def total
    tot.to_f
  end
end

class DayliReport < Struct.new(:tot, :date)
  def total
    tot.to_f
  end
end
