class AddAccountLedgersOldReference < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :account_ledgers do |t|
        t.string :old_reference
      end
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :account_ledgers do |t|
        t.remove :old_reference
      end
    end
  end
end
