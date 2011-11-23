class CreateClientAccounts < ActiveRecord::Migration
  def change
    create_table :client_accounts do |t|
      t.string :name
      t.integer :users
      t.integer :agencies
      t.boolean :branding
      t.integer :disk_space
      t.string :backup
      t.integer :stored_backups
      t.boolean :api
      t.boolean :report
      t.boolean :third_party_apps
      t.integer :free_days
      t.boolean :email # Email notifications

      t.timestamps
    end
  end
end
