class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :organisation_id, :limit => 36
      t.string :user_id, :limit => 36
      t.string :role
      t.string :settings
      t.boolean :creator

      t.timestamps
    end
    add_index :links, :id
    add_index :links, :user_id
    add_index :links, :organisation_id
  end

  def self.down
    drop_table :links
  end
end
