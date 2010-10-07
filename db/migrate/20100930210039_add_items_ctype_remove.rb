class AddItemsCtypeRemove < ActiveRecord::Migration
  def self.up
    #add_column :items, :ctype, :string, :limit => 20
    #change_column :items, :discount, :string
    #remove_column :items, :product
    #remove_column :items, :quantities

    #add_index :items, :ctype
  end

  def self.down
    #remove_column :items, :ctype
  end
end
