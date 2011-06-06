class RemoveContactsClientSupplier < ActiveRecord::Migration
  def up
    remove_column :contacts, :client, :supplier
  end

  def down
  end
end
