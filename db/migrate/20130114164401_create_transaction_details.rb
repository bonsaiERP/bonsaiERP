class CreateTransactionDetails < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :transaction_details do |t|
        t.integer :account_id
        t.integer :item_id

        t.decimal :quantity, :precision => 14, :scale => 2, default: 0.0
        t.decimal :price, :precision => 14, :scale => 2, default: 0.0
        t.string :description
        t.decimal :discount, :precision => 14, :scale => 2, default: 0.0
        t.decimal :balance, :precision => 14, :scale => 2, default: 0.0

        t.decimal  :original_price, :precision => 14, :scale => 2, default: 0.0
        t.timestamps
      end

      add_index :transaction_details, :account_id
      add_index :transaction_details, :item_id
    end
  end
end
