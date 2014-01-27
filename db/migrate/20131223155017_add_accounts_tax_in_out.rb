class AddAccountsTaxInOut < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :accounts do |t|
        t.boolean :tax_in_out, default: false
      end
      add_index :accounts, :tax_in_out # Needs onserver index
    end
  end
end
