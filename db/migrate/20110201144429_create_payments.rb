class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :transaction_id
      t.integer :organisation_id
      t.string :ctype

      t.date :date
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :interests_penalties, :precision => 14, :scale => 2
      t.string :description

      t.timestamps
    end

    add_index :payments, :transaction_id
    add_index :payments, :organisation_id
    add_index :payments, :ctype
    add_index :payments, :date
  end

  def self.down
    drop_table :payments
  end
end
