class AddAccountLedgersAmountFrom < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: ['common'] do
      change_table :account_ledgers do |t|
        t.decimal :amount_from, precision: 14, scale: 2, default: 0.0
      end
    end
  end

  def down
    PgTools.with_schemas except: ['common'] do
      remove_column :account_ledgers, :amount_from
    end
  end
end
