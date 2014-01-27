class AddAccountLedgersName < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_column :account_ledgers, :date, :date
      change_table :account_ledgers do |t|
        t.string :name
        t.index :name, unique: true
      end

      execute("UPDATE account_ledgers SET name = CONCAT('T-', SUBSTRING(EXTRACT(YEAR FROM date)::text FROM 3 FOR 4), '-', id)")
    end
  end
end
