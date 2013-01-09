class RemoveTransactionUsers < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.remove :creator_id
      t.remove :approver_id
      t.remove :approver_datetime
      t.remove :approver_reason
      t.remove :creditor_id
      t.remove :credit_reference
      t.remove :credit_datetime
      t.remove :credit_description
    end
  end

  def down
  end
end
