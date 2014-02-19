class AddGinIdexesAccountsAccountLedgers < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      # account_ledgers
      remove_column :account_ledgers, :description
      remove_column :account_ledgers, :old_reference
      remove_index :account_ledgers, :reference
      change_column :account_ledgers, :reference, :text
      execute 'CREATE INDEX index_account_ledgers_on_reference ON account_ledgers USING gin (reference gin_trgm_ops)'

      # accounts
      remove_index :accounts, :name
      remove_index :accounts, :description
      execute 'CREATE INDEX index_accounts_on_name ON accounts USING gin (name gin_trgm_ops)'
      execute 'CREATE INDEX index_accounts_on_description ON accounts USING gin (description gin_trgm_ops)'

    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      # account_ledgers
      add_column :account_ledgers, :description, :string
      add_column :account_ledgers, :old_reference, :string
      add_index :account_ledgers, :reference
      change_column :account_ledgers, :reference, :string

      # accounts
      remove_index :accounts, :name
      remove_index :accounts, :description
      # Normal btree indexes
      add_index :accounts, :name
      add_index :accounts, :description
    end
  end
end
