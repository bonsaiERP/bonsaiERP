class AddPayPlansOperation < ActiveRecord::Migration
  def self.up
    add_column :pay_plans, :operation, :string, :limit => 10
    add_index :pay_plans, :operation

    PayPlan.all.each do |pp|
      op = pp.transaction.is_a?(Income) ? "in" : "out"
      pp.update_attribute(:operation, op)
    end
  end

  def self.down
    remove_column :pay_plans, :operation
  end
end
