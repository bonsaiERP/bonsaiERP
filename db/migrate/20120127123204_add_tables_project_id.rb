class AddTablesProjectId < ActiveRecord::Migration
  def up
    add_column :account_ledgers, :project_id, :integer
    add_index  :account_ledgers, :project_id
    
    add_column :pay_plans, :project_id, :integer
    add_index  :pay_plans, :project_id

    add_column :inventory_operations, :project_id, :integer
    add_index  :inventory_operations, :project_id
  end

  def down
    remove_column :account_ledgers, :project_id
    remove_column :pay_plans, :project_id
    remove_column :inventory_operations, :project_id
  end
end
