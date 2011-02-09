class CreatePayPlans < ActiveRecord::Migration
  def self.up
    create_table :pay_plans do |t|
      t.integer :organisation_id
      t.integer :transaction_id
      t.integer :currency_id # Denormalized
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :interests_penalties, :precision => 14, :scale => 2
      t.date :payment_date
      t.date :alert_date
      t.boolean :email
      t.string :ctype, :limit => 10
      t.string :description
      t.boolean :paid, :default => false

      t.timestamps
    end

    add_index :pay_plans, :organisation_id
    add_index :pay_plans, :transaction_id
    add_index :pay_plans, :payment_date
    add_index :pay_plans, :ctype
    add_index :pay_plans, :paid
  end

  def self.down
    drop_table :pay_plans
  end
end
