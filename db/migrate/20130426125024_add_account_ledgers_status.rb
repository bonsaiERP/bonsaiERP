class AddAccountLedgersStatus < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      change_table :account_ledgers do |t|
        t.string :status, limit: 50, default: 'approved'
      end

      add_index :account_ledgers, :status
    end

    # Set status
    Organisation.pluck(:tenant).each do |tenant|
      if PgTools.schema_exists? tenant
        PgTools.change_schema tenant
        AccountLedger.where(active: false).update_all("status='nulled'")
        AccountLedger.where(active: true, conciliation: true).update_all("status='approved'")
        AccountLedger.where(active: true, conciliation: false).update_all("status='pendent'")
      end
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :account_ledgers do |t|
        t.remove :status
      end
    end
  end
end
