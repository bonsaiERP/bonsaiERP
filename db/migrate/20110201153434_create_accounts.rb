class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :currency_id
      t.integer :account_type_id
      t.integer :accountable_id
      t.string  :accountable_type# denormalized field to find accounts by model type
      t.string  :original_type, :limit => 20

      t.string  :name
      t.string  :type, :limit => 20
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :initial_amount, :precision => 14, :scale => 2

      t.string  :number

      t.timestamps
    end

    add_index :accounts, :currency_id
    add_index :accounts, :account_type_id
    add_index :accounts, :accountable_id
    add_index :accounts, :accountable_type
    add_index :accounts, :original_type
    add_index :accounts, :type
    #add_index :accounts, :number
  end
end
