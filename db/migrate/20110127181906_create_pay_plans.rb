class CreatePayPlans < ActiveRecord::Migration
  def self.up
    create_table :pay_plans do |t|
      t.integer :organisation_id
      t.integer :transaction_id
      t.integer :currency_id # Denormalized
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :interests_penalties, :precision => 14, :scale => 2
      t.date :payment_day
      t.date :alert_date
      t.boolean :email

      t.timestamps
    end

    add_index :pay_plans, :organisation_id
    add_index :pay_plans, :transaction_id
    add_index :pay_plans, :payment_day
  end

  def self.down
    drop_table :pay_plans
  end
end
