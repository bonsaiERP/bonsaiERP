# encoding: utf-8
class Report
  def expenses_by_item(attrs = {})
    data = params(attrs.merge(type: 'Expense'))
    conn.select_rows(sum_transaction_details_sql(data) ).map {|v| ItemTransReport.new(*v)}
  end

  def incomes_by_item(attrs = {})
    data = params(attrs.merge(type: 'Income'))
    conn.select_rows(sum_transaction_details_sql(data)).map {|v| ItemTransReport.new(*v)}
  end

  def total_expenses(drange = date_range)
    @total_expenses ||= Expense.active.joins(:transaction)
    .where('date BETWEEN ? AND ?', drange.date_start, drange.date_end)
    .sum('(transactions.total - accounts.amount) * accounts.exchange_rate')
  end

  def total_incomes(drange = date_range)
    @total_incomes ||= Income.active.joins(:transaction)
    .where('date BETWEEN ? AND ?', drange.date_start, drange.date_end)
    .sum('(transactions.total - accounts.amount) * accounts.exchange_rate')
  end

  def incomes_dayli(drange = date_range)
    data = params(type: 'Income', drange: drange)
    @incomes_dayli ||= conn.select_rows(dayli_sql(data)).map {|v| DayliReport.new(*v)}
  end

  def expenses_dayli(drange = date_range)
    data = params(type: 'Expense', drange: drange)
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
  def date_range
    @date_range ||= DateRange.default
  end

  def parse_date(attrs = {})
    case
    when attrs[:drange]
      attrs[:drange]
    when attrs[:date_range]
      attrs[:date_range]
    when(attrs[:date_start] && attrs[:date_end])
      DateRange.parse(attrs[:date_start], attrs[:date_end])
    when(attrs[:dates] && attrs[:datee])
      DateRange.parse(attrs[:dates], attrs[:datee])
    else
      DateRange.default
    end
  end

  def params(attrs = {})
    drange = parse_date(attrs)
    ReportParams.new({
      date_start: drange.date_start, date_end: drange.date_end,
      offset: 0, limit: 10
    }.merge(attrs))
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
      AND a.date BETWEEN '#{data.date_start}' AND '#{data.date_end}'
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
      AND a.date BETWEEN '#{data.date_start}' AND '#{data.date_end}'
      GROUP BY a.date
      ORDER BY a.date
    SQL
  end
end

class ReportParams < OpenStruct
end

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
