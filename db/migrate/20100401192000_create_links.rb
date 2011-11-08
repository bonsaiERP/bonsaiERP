class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :user_id
      t.integer :rol_id
      t.string :settings
      t.boolean :creator

      t.string   :rol, :limit => 50
      t.boolean  :active, :default => true

      t.timestamps
    end
    add_index :links, :user_id
  end
end
