class CreateTenant
  @queue = :create_tenant

  def self.perform(organisation_id)
    #begin
    org = Organisation.find(organisation_id)
    #rescue
    #  return
    #end
    #sql = %{CREATE SCHEMA "#{org.id}"}
    #ActiveRecord::Base.connection.execute sql
    PgTools.create_schema org.id
    #sql = "SET search_path to #{[org.id, "public"].join(",")}"
    #ActiveRecord::Base.connection.execute sql
    PgTools.set_search_path org.id, false

    org.class.transaction do
      load File.join(Rails.root, "db/schema.rb")

      Unit.create_base_data
      AccountType.create_base_data
    end
  end
end
