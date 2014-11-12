class AddAccountNameUniqueIndex < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      remove_index :accounts, :name
    end

    PgTools.with_schemas except: 'common' do
      add_index :accounts, :name, unique: true
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :accounts, :name
    end
  end
end
