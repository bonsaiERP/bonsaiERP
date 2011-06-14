class CreateAccountCurrencies < ActiveRecord::Migration
  def change
    create_table :account_currencies do |t|
      t.integer :organisation_id
      t.references :account
      t.references :currency
      t.decimal :amount, :precision => 14, :scale => 2

      t.timestamps
    end
    add_index :account_currencies, :account_id
    add_index :account_currencies, :currency_id
    add_index :account_currencies, :organisation_id
  end
end
