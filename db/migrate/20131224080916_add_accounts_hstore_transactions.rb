class AddAccountsHstoreTransactions < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      add_column :accounts, :extras, :hstore
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_column :accounts, :extras, :hstore
    end
  end
end
