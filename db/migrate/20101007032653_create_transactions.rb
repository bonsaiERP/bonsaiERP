class CreateTransactions < ActiveRecord::Migration
  def change
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
      t.decimal :exchange_rate, :precision => 14, :scale => 4, default: 1

      t.integer :project_id
      t.decimal :discount, :precision => 5,  :scale => 2, default: 0
      t.decimal :gross_total, :precision => 14, :scale => 2, default: 0
      t.boolean :cash, :default => true
      t.date    :payment_date
      t.decimal :balance_inventory, :precision => 14, :scale => 2
      # Creators approver
      t.integer :creator_id
      t.integer :approver_id
      t.datetime :approver_datetime
      t.string  :approver_reason
      # Credit details
      t.integer :creditor_id
      t.string  :credit_reference
      t.datetime :credit_datetime
      t.string  :credit_description, :limit => 500

      t.boolean :has_error, default: false
      t.string  :error_messages

      t.timestamps
    end

    add_index :transactions, :contact_id
    add_index :transactions, :active
    add_index :transactions, :ref_number
    add_index :transactions, :date
    add_index :transactions, :currency_id
    add_index :transactions, :state
    add_index :transactions, :balance_inventory
    add_index :transactions, :cash
    add_index :transactions, :payment_date
    add_index :transactions, :project_id

    add_index :transactions, :creditor_id
    add_index :transactions, :has_error

  end
end
