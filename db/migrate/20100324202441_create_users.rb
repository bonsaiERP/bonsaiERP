class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      # devise
      t.authenticatable
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.timestamps
      # user
      t.string :first_name, :limit => 80
      t.string :last_name, :limit => 80
      t.string :phone, :limit => 20
      t.string :mobile, :limit => 20
      t.string :website, :limit => 200
      t.string :account_type, :limit => 15
      t.text :description

      t.timestamps
    end
    add_index :users, :first_name
    add_index :users, :last_name

  end

  def self.down
    drop_table :users
  end
end
