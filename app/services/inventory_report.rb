# ir = InventoryReport.new(type: 'Income', start_date: '2014-07-01', end_date: '2014-07-16', state: 'approved')
class InventoryReport
  attr_reader :type, :start_date, :end_date, :state

  def initialize(attrs)
    @type = attrs[:type]
    @start_date = attrs[:start_date]
    @end_date = attrs[:end_date]
    @state = attrs[:state]
  end

  def due_date_sql
    sanitize_sql_array([
      range_sql('due_date'),
      {type: type, start_date: start_date, end_date: end_date, state: state}
    ])
  end

  def date_sql

  end

  def sanitize_sql_array(arr)
    ActiveRecord::Base.send(:sanitize_sql_array, arr)
  end

  def range_sql(date_field)
<<-SQL
SELECT items.name, SUM(details.quantity), items.unit_symbol
FROM items
JOIN movement_details as details ON (details.item_id = items.id)
WHERE details.account_id IN(
  SELECT id from accounts WHERE type= :type AND state = :state
  AND #{date_field} BETWEEN :start_date AND :end_date
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
