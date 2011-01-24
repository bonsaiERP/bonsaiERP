class CreateTransactionDetails < ActiveRecord::Migration
  def self.up
    create_table :transaction_details do |t|
      t.integer :transaction_id
      t.integer :item_id
      t.integer :currency_id

      t.decimal :quantity, :precision => 14, :scale => 2
      t.decimal :price, :precision => 14, :scale => 2
      t.string :description
      t.decimal :minimun, :precision => 14, :scale => 2
      t.decimal :maximun, :precision => 14, :scale => 2
      t.string :ctype, :limit => 30
      t.decimal :discount, :precision => 14, :scale => 2

      t.integer :organisation_id

      t.timestamps
    end

    add_index :transaction_details, :transaction_id
    add_index :transaction_details, :item_id
    add_index :transaction_details, :organisation_id
    add_index :transaction_details, :ctype
  end

  def self.down
    drop_table :transaction_details
  end
end
