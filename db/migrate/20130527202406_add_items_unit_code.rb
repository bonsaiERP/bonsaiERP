class AddItemsUnitCode < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.string :unit_symbol, limit: 20
        t.string :unit_name, limit: 255
      end

      change_column :items, :name, :string, limit: 255
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.remove :unit_symbol
        t.remove :unit_name
      end
    end
  end
end
