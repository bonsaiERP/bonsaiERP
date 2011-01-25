class CreateCurrencyRates < ActiveRecord::Migration
  def self.up
    create_table :currency_rates do |t|
      t.integer :currency_id
      t.decimal :rate, :precision => 14, :scale => 6
      t.boolean :active, :default => false

      t.integer :organisation_id

      t.timestamps
    end

    add_index :currency_rates, :currency_id
    add_index :currency_rates, :created_at
    add_index :currency_rates, :active
    add_index :currency_rates, :organisation_id
  end

  def self.down
    drop_table :currency_rates
  end
end
