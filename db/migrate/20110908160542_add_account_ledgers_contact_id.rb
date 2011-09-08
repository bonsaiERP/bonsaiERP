class AddAccountLedgersContactId < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.integer :contact_id
    end
    add_index :account_ledgers, :contact_id
  end

  def down
  end
end
