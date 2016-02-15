class RemoveIndexAccountsExtras < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: "common" do
      remove_index :accounts, :extras
    end
  end

  def down
  end
end
