class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :contact_id
      t.string  :type, :limit => 20
      
      t.decimal :total, :precision => 14, :scale => 2
      t.decimal :balance, :precision => 14, :scale => 2 # Saldo
      t.decimal :tax_percent, :precision => 5, :scale => 2

      t.boolean :active, :default => true
      t.string  :description
      t.string  :state, :limit => 20
      t.date    :date
      t.string  :ref_number
      t.string  :bill_number # factura

      t.integer :currency_id
      t.decimal :currency_exchange_rate, :precision => 14, :scale => 4

      t.integer :organisation_id

      t.integer :project_id
      t.decimal :discount, :precision => 5,  :scale => 2
      t.decimal :gross_total, :precision => 14, :scale => 2
      t.boolean :cash, :default => true
      t.date    :payment_date
      t.integer :creator_id
      t.integer :approver_id
      t.decimal :balance_inventory, :precision => 14, :scale => 2

      t.timestamps
    end

    add_index :transactions, :contact_id
    add_index :transactions, :active
    add_index :transactions, :ref_number
    add_index :transactions, :date
    add_index :transactions, :organisation_id
    add_index :transactions, :currency_id
    add_index :transactions, :state
    add_index :transactions, :balance_inventory
    add_index :transactions, :cash
    add_index :transactions, :payment_date
    add_index :transactions, :project_id
  end

  def self.down
    drop_table :transactions
  end
end
