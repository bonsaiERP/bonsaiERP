class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :organisation_id
      t.integer :currency_id
      t.string :name
      t.string :address
      t.string :phone
      t.string :email
      t.string :website
      t.string :number, :limit => 50
      t.string :type, :limit => 20
      t.decimal :total_amount, :precision => 14, :scale => 2

      t.timestamps
    end

    add_index :accounts, :organisation_id
    add_index :accounts, :currency_id
    add_index :accounts, :type
    add_index :accounts, :number
  end

  def self.down
    drop_table :accounts
  end
end
