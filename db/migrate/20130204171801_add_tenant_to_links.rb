class AddTenantToLinks < ActiveRecord::Migration
  def change
    change_table "common.links" do |t|
      t.string :tenant, limit: 100
    end

    add_index "common.links", :tenant

    Link.connection.execute("UPDATE common.links AS l SET tenant=o.tenant FROM common.organisations AS o WHERE o.id=l.organisation_id")
  end
end
