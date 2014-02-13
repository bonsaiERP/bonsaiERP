class AddCreatorIdToItems < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.integer :creator_id
        t.index :creator_id
      end
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :items, :creator_id
      remove_column :items, :creator_id
    end
  end
end
