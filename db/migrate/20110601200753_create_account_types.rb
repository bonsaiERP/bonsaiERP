class CreateAccountTypes < ActiveRecord::Migration
  def change
    create_table :account_types do |t|
      t.string :name
      t.string :number
      t.string :account_number

      t.timestamps
    end
    add_index :account_types, :account_number
  end
end
