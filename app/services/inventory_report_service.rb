# ir = InventoryReport.new(type: 'Income', start_date: '2014-07-01', end_date: '2014-07-16', state: 'approved')
class InventoryReportService
  attr_reader :type, :date_start, :date_end, :state, :date_field

  def initialize(attrs)
    @date_field = attrs[:date_field]
    @type = attrs[:type]
    @state= attrs[:state]
    @date_start = attrs[:date_start]
    @date_end = attrs[:date_end]
    @state = attrs[:state]
  end

  def data
    ActiveRecord::Base.connection.select_rows(sql)
  end

  def self.date_fields
    [['Fecha', 'date'], ['Fecha vencimiento', 'due_date']]
  end

  def self.types
    [['Ingreso', 'Income'], ['Egreso' ,'Expense']]
  end

  def self.states
    [ ['aprobado', 'approved'], ['atrasado','nulled'], ['borrador','draft']]
  end

  def sql
    sanitize_sql_array([
      range_sql,
      { type: type, date_start: date_start, date_end: date_end, state: state }
    ])
  end

  def sanitize_sql_array(arr)
    ActiveRecord::Base.send(:sanitize_sql_array, arr)
  end

  def range_sql
<<-SQL
SELECT items.name, SUM(details.quantity), items.unit_symbol
FROM items
JOIN movement_details as details ON (details.item_id = items.id)
WHERE details.account_id IN(
  SELECT id from accounts WHERE type= :type AND state = :state
  AND #{date_field} BETWEEN :date_start AND :date_end
)
GROUP BY items.id
SQL
  end

end
=begin
set search_path to bonsai;

select items.name, sum(details.quantity), items.unit_symbol FROM items
JOIN movement_details as details ON (details.item_id = items.id)
WHERE details.account_id IN(
    select id from accounts where type='Income' and state='approved'
and due_date <= '2014-07-19'
)
GROUP BY items.id
=end
