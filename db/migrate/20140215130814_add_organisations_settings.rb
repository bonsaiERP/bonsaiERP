class AddOrganisationsSettings < ActiveRecord::Migration
  def up
    PgTools.with_schemas %w(public common) do
      change_table :organisations do |t|
        t.hstore :settings
      end
      change_column_default :organisations, :settings, inventory: true
    end
  end

  def down
    PgTools.with_schemas %w(public common) do
      remove_column :organisations, :settings
    end
  end
end
