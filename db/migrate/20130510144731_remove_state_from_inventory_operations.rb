class RemoveStateFromInventoryOperations < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      remove_column :inventory_operations, :state
    end
  end

  def down
  end
end
