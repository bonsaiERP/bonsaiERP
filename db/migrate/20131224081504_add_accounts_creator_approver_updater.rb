class AddAccountsCreatorApproverUpdater < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.integer :creator_id
      t.integer :approver_id
      t.integer :nuller_id
    end

    add_index :accounts, :creator_id
    add_index :accounts, :approver_id
    add_index :accounts, :nuller_id
    # add_index :accounts, :updater_id
  end
end
