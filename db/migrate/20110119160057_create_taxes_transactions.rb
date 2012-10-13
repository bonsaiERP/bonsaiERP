class CreateTaxesTransactions < ActiveRecord::Migration
  def change
    create_table :taxes_transactions, :id => false do |t|
      t.integer :tax_id
      t.integer :transaction_id
    end

    add_index :taxes_transactions, :tax_id
    add_index :taxes_transactions, :transaction_id
    add_index :taxes_transactions, [:tax_id, :transaction_id]
  end
end
