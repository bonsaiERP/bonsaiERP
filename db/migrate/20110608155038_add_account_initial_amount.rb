class AddAccountInitialAmount < ActiveRecord::Migration
  def up
    change_table :accounts do |t|
      t.decimal :initial_amount, :precision => 14, :scale => 2
    end
  end

  def down
  end
end
