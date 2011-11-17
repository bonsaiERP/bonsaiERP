class AddTransactionDetailsDelivered < ActiveRecord::Migration
  def up
    change_table :transaction_details do |t|
      t.decimal :delivered, :precision => 14, :scale => 2, :default => 0
    end
  end

  def down
    remove_column :transaction_details, :delivered
  end
end
