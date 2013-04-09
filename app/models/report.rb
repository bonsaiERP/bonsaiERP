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

  def params(attrs = {})
    ReportParams.new({start_date: date_range.start_date, end_date: date_range.end_date,
      offset: 0, limit: 10
    }.merge(attrs))
  end

private
  def date_range
    @date_range ||= DateRange.default
  end

  def conn
    ActiveRecord::Base.connection
  end

  def sum_transaction_details_sql(data)
    <<-SQL
      SELECT i.id, i.name, SUM(d.price * d.quantity * a.exchange_rate) AS total
      FROM transaction_details d JOIN items i ON (i.id = d.item_id)
      JOIN accounts a ON (a.id = d.account_id)
      WHERE a.type = '#{data.type}' AND a.date BETWEEN '#{data.start_date}' AND '#{data.end_date}'
      GROUP BY (i.id)
      ORDER BY total DESC
      OFFSET #{data.offset} LIMIT #{data.limit}
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
