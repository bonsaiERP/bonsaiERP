class AddOrganisationsActiveInventory < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: 'common' do
      change_table :organisations do |t|
        t.boolean :inventory_active, default: true
      end
    end
  end

  def down
    PgTools.with_schemas only: 'common' do
      change_table :organisations do |t|
      end
    end
  end
end
