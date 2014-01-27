class CreateTransactions < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do

      create_table :transactions do |t|
        t.integer :account_id

        # Use Account#amount for total, create alias
        t.decimal :total, precision: 14, scale: 2, default: 0.0

        # Use Account#name for ref_number create alias
        t.string  :bill_number

        t.decimal :gross_total, precision: 14, scale: 2, default: 0.0
        t.decimal :original_total, precision: 14, scale: 2, default: 0.0
        t.decimal :balance_inventory, precision: 14, scale: 2, default: 0.0

        t.date    :due_date
        # Creators approver
        t.integer  :creator_id
        t.integer  :approver_id
        t.integer  :nuller_id
        t.datetime :nuller_datetime
        t.string   :null_reason, limit: 400
        t.datetime :approver_datetime

        t.boolean :delivered, default: false
        t.boolean :discounted, default: false
        t.boolean :devolution, default: false

        t.timestamps
      end

      add_index :transactions, :account_id, unique: true
      add_index :transactions, :due_date
      add_index :transactions, :delivered
      add_index :transactions, :discounted
      add_index :transactions, :devolution
      add_index :transactions, :bill_number
    end
  end
end
