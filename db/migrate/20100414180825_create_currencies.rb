class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :name, :limit => 100
      t.string :symbol, :limit => 20

      t.timestamps
    end
    add_index(:currencies, :id)
  end

  def self.down
    drop_table :currencies
  end
end
