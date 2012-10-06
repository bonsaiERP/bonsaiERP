class AddOrganisationsClientAccount < ActiveRecord::Migration
  def up
    change_table "common.organisations" do |t|
      t.integer :client_account_id, :default => 1
    end

    add_index  "common.organisations", :client_account_id
  end

  def down
    remove_column "common.organisations", :client_account_id
  end
end
