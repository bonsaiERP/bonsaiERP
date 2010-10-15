class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :contact_id
      t.string :type, :limit => 20
      t.decimal :total, :precision => 14, :scale => 2
      t.decimal :balance, :precision => 14, :scale => 2 # Saldo
      t.boolean :active
      t.string :description
      t.string :state
      t.date :date
      t.string :ref_number

      t.integer :currency_id
      t.decimal :currency_exchange_rate, :precision => 14, :scale => 6

      t.integer :organisation_id

      t.timestamps
    end

    add_index :transactions, :contact_id
    add_index :transactions, :active
    add_index :transactions, :ref_number
    add_index :transactions, :date
    add_index :transactions, :organisation_id
  end

  def self.down
    drop_table :transactions
  end
end
