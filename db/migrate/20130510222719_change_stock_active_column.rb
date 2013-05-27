class ChangeStockActiveColumn < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :stocks do |t|
        t.boolean :active, default: true
        t.remove :state

        # Index
        t.index :active
      end
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :stocks do |t|
        t.remove :active
      end
    end
  end
end
