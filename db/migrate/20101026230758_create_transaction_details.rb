class CreateTransactionDetails < ActiveRecord::Migration
  def change
    create_table :transaction_details do |t|
      t.integer :transaction_id
      t.integer :item_id
      t.integer :currency_id

      t.decimal :quantity, :precision => 14, :scale => 2
      t.decimal :price, :precision => 14, :scale => 2
      t.string :description
      t.string :ctype, :limit => 30
      t.decimal :discount, :precision => 14, :scale => 2
      t.decimal :balance, :precision => 14, :scale => 2

      t.decimal  :original_price, :precision => 14, :scale => 2
      t.timestamps
    end

    add_index :transaction_details, :transaction_id
    add_index :transaction_details, :item_id
    add_index :transaction_details, :ctype
  end
end
