class CreateAccountLedgerDetails < ActiveRecord::Migration
  def change
    create_table :account_ledger_details do |t|
      t.references :organisation
      t.references :account
      t.references :account_ledger
      t.references :related_id
      t.decimal    :amount, :presicion => 14, :scale => 2
      t.decimal    :exchange_rate, :precision => 14, :scale => 4
      t.string     :description
      t.boolean    :active, :default => true
      t.string     :state, :limit => 20

      t.timestamps
    end
    add_index :account_ledger_details, :organisation_id
    add_index :account_ledger_details, :account_id
    add_index :account_ledger_details, :account_ledger_id
    add_index :account_ledger_details, :related_id
    add_index :account_ledger_details, :active
    add_index :account_ledger_details, :state
  end
end
