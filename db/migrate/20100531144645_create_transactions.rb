class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :contact_id
      t.string :type, :limit => 20
      t.decimal :total, :precision => 14, :scale => 2
      t.boolean :active, :default => true
      t.string :description
      t.string :state, :limit => 20
      t.date :date
      t.decimal :balance, :precision => 14, :scale => 2

      t.integer :organisation_id, :null => false

      t.timestamps
    end

    add_index :transactions, :contact_id
    add_index :transactions, :state
    add_index :transactions, :organisation_id
    add_index :transactions, :state
  end

  def self.down
    drop_table :transactions
  end
end
