# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CreateUsers < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: ['common','public'] do
      create_table :users do |t|
        # user
        t.string :email, null: false
        t.string :first_name, :limit => 80
        t.string :last_name, :limit => 80
        t.string :phone, :limit => 20
        t.string :mobile, :limit => 20
        t.string :website, :limit => 200
        t.string :description, :limit => 255

        # Control users
        t.string   :encrypted_password
        t.string   :password_salt
        t.string   :confirmation_token, :limit => 60
        t.datetime :confirmation_sent_at
        t.datetime :confirmed_at
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at
        t.datetime :reseted_password_at
        t.integer  :sign_in_count, :default => 0
        t.datetime :last_sign_in_at

        t.boolean :change_default_password, :default => false
        t.string :address

        t.boolean :active, default: true
        t.string :auth_token

        t.string :rol, limit: 50

        t.timestamps
      end

      add_index :users, :email, unique: true
      add_index :users, :first_name
      add_index :users, :last_name
      add_index :users, :confirmation_token, unique: true
      add_index :users, :auth_token, unique: true
    end
  end

end
