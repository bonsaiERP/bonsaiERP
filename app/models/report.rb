# encoding: utf-8
class Report
  def expenses_by_item(drange = DateRange.default)
    conn.select_rows(sum_transaction_details_sql('Expense', drange)).map {|v| DetReport.new(*v)}
  end

  def incomes_by_item(drange = DateRange.default)
    conn.select_rows(sum_transaction_details_sql('Income', drange)).map {|v| DetReport.new(*v)}
  end

private
  def conn
    ActiveRecord::Base.connection
  end

  def sum_transaction_details_sql(type, drange)
    <<-SQL
      SELECT i.id, i.name, SUM(d.price * d.quantity * a.exchange_rate) AS total
      FROM transaction_details d JOIN items i ON (i.id = d.item_id)
      JOIN accounts a ON (a.id = d.account_id)
      WHERE a.type = '#{type}' AND a.date BETWEEN '#{drange.sdate}' AND '#{drange.edate}'
      GROUP BY (i.id)
      ORDER BY total DESC
      LIMIT 10
    SQL
  end
end

class DateRange < Struct.new(:start_date, :end_date)
  alias :sdate :start_date
  alias :edate :end_date

  def self.default
    d = Date.today
    new(d - 30.days, d)
  end

  def self.last(days = 30)
    d = Date.today
    new(d - days.days, d)
  end

  def self.range(s, e)
    s, e = (s.is_a?(String) ? Date.parse(s) : s), (e.is_a?(String) ? Date.parse(e) : e)
    new(s, e)
  end
end

class DetReport < Struct.new(:id, :name, :tot)
  def total
    tot.to_f
  end
end
