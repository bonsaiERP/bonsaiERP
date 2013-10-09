class AddAccountsTaxId < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :accounts do |t|
        t.decimal :tax_percentage, precision: 5, scale: 2, default: 0
        t.integer :tax_id
      end

      add_index :accounts, :tax_id
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :accounts, :tax_id
      remove_column :accounts, :tax_id
      remove_column :accounts, :tax_precentage
    end
  end
end
