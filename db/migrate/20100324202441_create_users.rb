# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      # user
      t.string :email
      t.string :first_name, :limit => 80
      t.string :last_name, :limit => 80
      t.string :phone, :limit => 20
      t.string :mobile, :limit => 20
      t.string :website, :limit => 200
      t.string :account_type, :limit => 15
      t.string :description, :limit => 255

      # Control users
      t.string   :password_digest
      t.string   :confirmation_token, :limit => 20
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :reseted_password_at
      t.integer  :sign_in_count, :default => 0
      t.datetime :last_sign_in_at

      t.boolean :change_default_password, :default => false
      t.string :address

      t.timestamps
    end
    add_index :users, :email
    add_index :users, :first_name
    add_index :users, :last_name

  end

end
