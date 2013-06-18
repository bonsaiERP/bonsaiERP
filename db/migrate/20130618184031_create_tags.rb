class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :bgcolor, limit: 10

      t.timestamps
    end
  end
end
