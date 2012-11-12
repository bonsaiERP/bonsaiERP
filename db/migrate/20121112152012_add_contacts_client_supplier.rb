class AddContactsClientSupplier < ActiveRecord::Migration
  def up
    change_table :contacts do |t|
      t.boolean :client, default: false
      t.boolean :supplier, default: false
    end

    add_index :contacts, :client
    add_index :contacts, :supplier
  end

  def down
    change_table :contacts do |t|
      t.remove :client
      t.remove :supplier
    end
  end
end
