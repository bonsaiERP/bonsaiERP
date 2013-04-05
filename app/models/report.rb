# encoding: utf-8
class Report
  def expenses_by_item(drange = DateRange.default)
    ids = Expense.active.where("date BETWEEN ? AND ?", drange.sdate, drange.edate).map(&:id)

    conn.select_rows(sum_transaction_details_sql(ids)).map {|v| DetReport.new(*v)}
  end

  def incomes_by_item(drange = DateRange.default)
    ids = Income.active.where("date BETWEEN ? AND ?", drange.sdate, drange.edate).map(&:id)

    conn.select_rows(sum_transaction_details_sql(ids)).map {|v| DetReport.new(*v)}
  end

private
  def conn
    ActiveRecord::Base.connection
  end

  def sum_transaction_details_sql(ids)
    <<-SQL
      SELECT i.id, i.name, SUM(d.price * d.quantity * a.exchange_rate) AS total
      FROM transaction_details d JOIN items i ON (i.id = d.item_id)
      JOIN accounts a ON (a.id = d.id)
      WHERE d.account_id in (#{ids.join(", ")})
      GROUP BY (i.id)
      ORDER by total DESC
    SQL
  end
end

class DateRange < Struct.new(:sdate, :edate)
  def self.default
    d = Date.today
    new(d - 30.days, d)
  end
end

class DetReport < Struct.new(:id, :name, :tot)
  def total
    tot.to_f
  end
end
