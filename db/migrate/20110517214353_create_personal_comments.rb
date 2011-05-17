class CreatePersonalComments < ActiveRecord::Migration
  def self.up
    create_table :personal_comments do |t|
      t.integer :account_ledger_id
      t.integer :organisation_id
      t.text :comment

      t.timestamps
    end

    add_index :personal_comments, :account_ledger_id
    add_index :personal_comments, :organisation_id
  end

  def self.down
    drop_table :personal_comments
  end
end
