class AddHistoriesKlassType < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      add_column :histories, :klass_type, :string
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_column :histories, :klass_type
    end
  end
end
