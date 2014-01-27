class RemoveUserChanges < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      drop_table :user_changes
      drop_table :money_stores
      drop_table :transaction_histories
    end
  end
end
