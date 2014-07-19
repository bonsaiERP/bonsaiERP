class CreateTagGroups < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :tag_groups do |t|
        t.string :name
        t.string :bgcolor
        t.integer :tag_ids, integer: true, array: true, default: []

        t.timestamps
      end

      add_index :tag_groups, :name, unique: true
      add_index :tag_groups, :tag_ids, using: :gin
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      drop_table :tag_groups
    end
  end
end
