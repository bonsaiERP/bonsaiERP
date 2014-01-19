class AddAccountsTotal < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      # Add to accounts
      add_column :accounts, :total, :decimal, precision: 14, scale: 2, default: 0

      # Updates
      execute("UPDATE accounts a SET total = t.total FROM transactions t WHERE (t.account_id = a.id)")

      #execute("UPDATE accounts a SET total = le.total FROM loan_extras le WHERE (le.loan_id = a.id)")

      # Remove from RELATED
      #remove_column :transactions, :total
      #remove_column :loan_extras, :total
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      # Remove from RELATED
      add_column :transactions, :total, :decimal, precision: 14, scale: 2, default: 0
      add_column :loan_extras, :total, :decimal, precision: 14, scale: 2, default: 0

      # Updates
      execute("UPDATE transactions t SET total = a.total FROM accounts a WHERE (t.account_id = a.id)")
      execute("UPDATE loan_extras le SET total = a.total FROM accounts a WHERE (le.loan_id = a.id)")

      # Add to accounts
      remove_column :accounts, :total, precision: 14, scale: 2
    end
  end
end
