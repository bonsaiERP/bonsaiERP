class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :parent_id, :limit => 36
      t.string :contact_id
      t.string :transactionable_id, :limit => 36
      t.string :transactionable_type
      t.string :name
      t.string :type, :limit => 20
      t.decimal :total, :precision => 14, :scale => 2
      t.boolean :active
      t.string :description
      t.string :state

      t.string :organisation_id, :limit => 36, :null => false

      t.timestamps
    end


    add_index(:transactions, :id)
    add_index(:transactions, :transactionable_id)
    add_index(:transactions, :transactionable_type)
    add_index(:transactions, :state)
    add_index(:transactions, :organisation_id)
  end

  def self.down
    drop_table :transactions
  end
end
