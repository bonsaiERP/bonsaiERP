class AddUsersOldEmails < ActiveRecord::Migration
  def up
    PgTools.with_schemas %w(common public) do
      add_column :users, :old_emails, :text, array: true, default: []
    end
  end

  def down
    PgTools.with_schemas %w(common public) do
      remove_column :users, :old_emails
    end
  end
end
