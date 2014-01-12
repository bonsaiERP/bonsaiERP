class UpdateAccountsDueDateExtrasIndex < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      execute 'UPDATE accounts a SET due_date = t.due_date FROM transactions t WHERE t.account_id = a.id'

      add_index :accounts, :extras, using: :gist
      #add_index :accounts, "(extras->'delivered')", name: 'index_accounts_on_extras_delivered'#, using: :gist, name: 'index_accounts_on_extras_delivered'
      #execute "CREATE INDEX index_accounts_on_extras_delivered ON accounts USING GIST(extras->'delivered')"
      #execute "CREATE INDEX index_accounts_on_extras_devolution ON accounts USING GIST((extras->'devolution')"
      #execute "CREATE INDEX index_accounts_on_extras_no_inventory ON accounts USING GIST((extras->'no_inventory')"
    end
  end

  def down
    remove_index :accounts, :extras
  end
end
