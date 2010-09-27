# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :name, :limit => 100
      t.string :symbol, :limit => 20
      t.string :code, :limit => 5

      t.timestamps
    end
  end

  def self.down
    drop_table :currencies
  end
end
