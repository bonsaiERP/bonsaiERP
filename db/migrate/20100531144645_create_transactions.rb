class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :parent_id
      t.integer :contact_id
      t.integer :transactionable_id, :limit => 36
      t.string :transactionable_type
      t.string :name
      t.string :type, :limit => 20
      t.decimal :total, :precision => 14, :scale => 2
      t.boolean :active
      t.string :description
      t.string :state

      t.integer :organisation_id
      t.date :date

      t.timestamps
    end


    add_index :transactions, :parent_id
    add_index :transactions, :contact_id
    add_index :transactions, :transactionable_id
    add_index :transactions, :transactionable_type
    add_index :transactions, :state
    add_index :transactions, :organisation_id
  end

  def self.down
    drop_table :transactions
  end
end
