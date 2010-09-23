class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :organisation_id
      t.integer :user_id
      t.integer :rol_id
      t.string :settings
      t.boolean :creator

      t.timestamps
    end
    add_index :links, :user_id
    add_index :links, :organisation_id
  end

  def self.down
    drop_table :links
  end
end
