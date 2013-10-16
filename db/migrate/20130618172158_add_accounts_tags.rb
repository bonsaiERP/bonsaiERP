class AddAccountsTags < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      add_column :accounts, :tag_ids, :integer, array: true, default: []
      add_index :accounts, :tag_ids, using: 'gin'
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :accounts, :tag_ids
      remove_column :accounts, :tag_ids
    end
  end
end
