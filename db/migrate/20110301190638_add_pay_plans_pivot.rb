class AddPayPlansPivot < ActiveRecord::Migration
  def self.up
    add_column :pay_plans, :pivot, :boolean, :default => false
  end

  def self.down
    remove_column :pay_plans, :pivot
  end
end
