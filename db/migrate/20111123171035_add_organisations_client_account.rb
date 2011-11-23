class AddOrganisationsClientAccount < ActiveRecord::Migration
  def up
    change_table :organisations do |t|
      t.integer :client_account_id, :default => 1
    end
    add_index  :organisations, :client_account_id
  end

  def down
    remove_column :organisations, :client_account_id
  end
end
