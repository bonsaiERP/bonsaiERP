class AddLinksAbbreviation < ActiveRecord::Migration
  def up
    change_table :links do |t|
      t.string :abbreviation, :limit => 15
    end
  end

  def down
  end
end
