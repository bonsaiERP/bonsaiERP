class UpdateIncomesExpensesHstoreTransactions < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      execute <<-SQL
UPDATE accounts a SET extras = HSTORE('bill_number', t.bill_number) ||
HSTORE('gross_total', t.gross_total::text) ||
HSTORE('original_total', t.original_total::text) ||
HSTORE('balance_inventory', t.balance_inventory::text) ||
HSTORE('nuller_datetime', t.nuller_datetime::text) ||
HSTORE('null_reason', t.null_reason) ||
HSTORE('approver_datetime', t.approver_datetime::text) ||
HSTORE('delivered', t.delivered::text) ||
HSTORE('discounted', t.discounted::text) ||
HSTORE('devolution', t.devolution::text) ||
HSTORE('no_inventory', t.no_inventory::text)
FROM transactions t
WHERE t.account_id = a.id AND a.type IN ('Income', 'Expense');
      SQL
    end
  end

  def down
    puts 'Nothing to change'
  end
end
