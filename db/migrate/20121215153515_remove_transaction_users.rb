class RemoveTransactionUsers < ActiveRecord::Migration
  def up
    if User.column_names.include? "creator_id"
      change_table :transactions do |t|
        t.remove :creator_id
        t.remove :approver_id
        t.remove :approver_datetime
        t.remove :approver_reason
        t.remove :creditor_id
        t.remove :credit_reference
        t.remove :credit_datetime
        t.remove :credit_description
        t.remove :deliver_approver_id
        t.remove :deliver_datetime
        t.remove :deliver_reason
        t.remove :nuller_id
        t.remove :nuller_datetime
      end
    end
  end

  def down
  end
end
