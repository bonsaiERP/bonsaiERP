class CreateAccounts < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :accounts do |t|
        t.string  :name
        t.string  :currency, limit: 10
        t.decimal :exchange_rate, precision: 14, scale: 4, default: 1.0
        t.decimal :amount, precision: 14, scale: 2, default: 0.0

        t.string  :type, limit: 30

        t.integer :contact_id
        t.integer :project_id
        t.boolean :active, default: true
        t.string  :description, limit: 500
        t.date    :date
        t.string  :state, limit: 30
        t.boolean :has_error, default: false
        t.string  :error_messages, limit: 400

        t.timestamps
      end

      add_index :accounts, :name, unique: true
      add_index :accounts, :amount
      add_index :accounts, :currency
      add_index :accounts, :type
      add_index :accounts, :contact_id
      add_index :accounts, :project_id
      add_index :accounts, :active
      add_index :accounts, :date
      add_index :accounts, :state
      add_index :accounts, :has_error
    end
  end
end
