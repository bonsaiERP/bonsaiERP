class CreateTransactionHistories < ActiveRecord::Migration
  def change
    create_table :transaction_histories do |t|
      t.integer :transaction_id
      t.integer :user_id
      t.text    :data

      t.timestamps
    end

    add_index :transaction_histories, :transaction_id
    add_index :transaction_histories, :user_id
  end
end
