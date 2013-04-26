class RemoveActiveConciliationFromAccountLedgers < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :account_ledgers do |t|
        t.remove :conciliation
        t.remove :active
      end
    end
  end

  def down
  end
end
