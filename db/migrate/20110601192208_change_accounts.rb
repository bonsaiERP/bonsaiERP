class ChangeAccounts < ActiveRecord::Migration
  def up
    rename_column :accounts, :total_amount, :amount
    change_table :accounts do |t|
      t.remove :number
      t.remove :address
      t.remove :email
      t.remove :phone
      t.remove :website
      t.references :accountable, :polymorphic => true
      t.references :account_type
    end
    add_index :accounts, :account_type_id
    add_index :accounts, :accountable_id
    add_index :accounts, :accountable_type
  end

  def down
  end
end
