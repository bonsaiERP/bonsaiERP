# ir = InventoryReport.new(type: 'Income', start_date: '2014-07-01', end_date: '2014-07-16', state: 'approved')
class InventoryReportService
  attr_reader :type, :date_start, :date_end, :state, :date_field, :tag_group_id

  def initialize(attrs)
    @date_field = attrs[:date_field]
    @type = attrs[:type]
    @state= attrs[:state]
    @date_start = attrs[:date_start]
    @date_end = attrs[:date_end]
    @state = attrs[:state]
    @tag_group_id = attrs[:tag_group_id]
  end

  def data
    ActiveRecord::Base.connection.select_rows(sql)
  rescue
    []
  end

  def self.date_fields
    [['Fecha', 'accounts.date'], ['Fecha vencimiento', 'accounts.due_date']]
  end

  def self.types
    [['Ingreso', 'Income'], ['Egreso' ,'Expense']]
  end

  def self.states
    [['Aprobado', 'approved'], ['Pagado', 'paid'], ['Anulado','nulled'], ['Borrador', 'draft']]
  end

  def sql
    query = if tag_group
              range_sql_tag_group
            else
              range_sql
            end

    sanitize_sql_array([
      query,
      { type: type, date_start: date_start, date_end: date_end, state: state }
    ])
  end

  def sanitize_sql_array(arr)
    ActiveRecord::Base.send(:sanitize_sql_array, arr)
  end

  def tag_group
    @tag_group ||= TagGroup.find_by(id: tag_group_id)
  end

  def range_sql_tag_group
<<-SQL
SELECT items.name, SUM(details.balance) as quantity, items.unit_symbol,
to_json(accounts.tag_ids) AS tag_ids
FROM items
JOIN movement_details as details ON (details.item_id = items.id)
JOIN (
  SELECT id, array_intersection(tag_ids, ARRAY#{ tag_group.tag_ids }) AS tag_ids,
  type, state, date, due_date
  FROM accounts
) AS accounts
ON (details.account_id = accounts.id)
WHERE accounts.type = :type AND accounts.state = :state
AND #{date_field} BETWEEN :date_start AND :date_end
GROUP BY items.id, accounts.tag_ids
ORDER BY items.name
SQL
  end

  def range_sql
<<-SQL
SELECT items.name, SUM(details.balance) AS quantity, items.unit_symbol
FROM items
JOIN movement_details as details ON (details.item_id = items.id)
JOIN accounts
ON (details.account_id = accounts.id)
WHERE accounts.type = :type AND accounts.state = :state
AND #{date_field} BETWEEN :date_start AND :date_end
GROUP BY items.id
ORDER BY items.name
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
