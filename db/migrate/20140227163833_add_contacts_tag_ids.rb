class AddContactsTagIds < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      add_column :contacts, :tag_ids, :integer, array: true, default: []
      add_index :contacts, :tag_ids, using: 'gin'
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :contacts, :tag_ids
      remove_column :contacts, :tag_ids
    end
  end
end
