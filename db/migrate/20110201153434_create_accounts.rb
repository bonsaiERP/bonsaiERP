class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :organisation_id
      t.integer :currency_id
      t.integer :account_type_id
      t.integer :accountable_id
      t.string  :accountable_type
  
      t.string  :name
      t.string  :type, :limit => 20
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :initial_amount, :precision => 14, :scale => 2

      t.string  :number

      t.timestamps
    end

    add_index :accounts, :organisation_id
    add_index :accounts, :currency_id
    add_index :accounts, :account_type_id
    add_index :accounts, :accountable_id
    add_index :accounts, :accountable_type
    add_index :accounts, :type
    #add_index :accounts, :number
  end

  def self.down
    drop_table :accounts
  end
end
