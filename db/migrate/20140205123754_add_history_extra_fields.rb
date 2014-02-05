class AddHistoryExtraFields < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :histories do |t|
        t.hstore :extras
        t.text :all_data
      end
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :histories do |t|
        t.remove :extras
        t.remove :all_data
      end
    end
  end
end
