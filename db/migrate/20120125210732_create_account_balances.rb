class CreateAccountBalances < ActiveRecord::Migration
  def change
    create_table :account_balances do |t|
      t.integer :user_id
      t.integer :contact_id
      t.integer :account_id
      t.integer :currency_id
      t.decimal :amount, :precision => 14, :scale => 4
      t.decimal :old_amount, :precision => 14, :scale => 2

      t.timestamps
    end

    add_index :account_balances, :user_id
    add_index :account_balances, :contact_id
    add_index :account_balances, :account_id
    add_index :account_balances, :currency_id
  end
end
