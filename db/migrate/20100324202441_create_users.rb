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
      t.string :first_name
      t.string :last_name
      t.text :description
      t.string :phone
      t.string :mobile
      t.string :website

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
