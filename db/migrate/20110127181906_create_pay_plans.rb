class CreatePayPlans < ActiveRecord::Migration
  def change
    create_table :pay_plans do |t|
      t.integer :transaction_id
      t.integer :currency_id # Denormalized
      t.string  :cur # denormalized
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :interests_penalties, :precision => 14, :scale => 2
      t.date    :payment_date
      t.date    :alert_date
      t.boolean :email, :default => true
      t.string  :ctype, :limit => 20
      t.string  :description
      t.boolean :paid, :default => false

      t.string   :operation, :limit => 20

      t.timestamps
    end

    add_index :pay_plans, :transaction_id
    add_index :pay_plans, :payment_date
    add_index :pay_plans, :ctype
    add_index :pay_plans, :paid
    add_index :pay_plans, :operation
  end
end
