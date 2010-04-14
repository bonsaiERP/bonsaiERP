class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :name, :limit => 100
      t.string :symbol, :litmi => 20

      t.timestamps
    end
  end

  def self.down
    drop_table :currencies
  end
end
