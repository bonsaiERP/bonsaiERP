class CreateTransactionHistories < ActiveRecord::Migration
  def change
    create_table :transaction_histories do |t|
      t.integer :account_id
      t.integer :user_id
      t.text    :data

      t.timestamps
    end

    add_index :transaction_histories, :account_id
    add_index :transaction_histories, :user_id
  end
end
