class AddTenantToLinks < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: ['common', 'public'] do
      change_table :links do |t|
        t.string :tenant, limit: 100
      end

      add_index :links, :tenant

      Link.connection.execute("UPDATE common.links AS l SET tenant=o.tenant FROM common.organisations AS o WHERE o.id=l.organisation_id")
    end
  end
end
