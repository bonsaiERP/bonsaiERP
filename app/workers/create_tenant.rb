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
    #sql = "SET search_path to #{[org.id, "public"].join(",")}"
    #ActiveRecord::Base.connection.execute sql

    org.class.transaction do
      PgTools.create_schema org.id
      PgTools.set_search_path org.id, false

      load File.join(Rails.root, "db/schema.rb")

      Unit.create_base_data
      AccountType.create_base_data
      Currency.create_base_data
      OrgCountry.create_base_data

      data = org.attributes
      data.delte("id")
      data.delete("user_id")
      Organisation.create!(data) {|orga| 
        orga.id = org.id
        orga.user_id = org.user_id
      }

      #User.create!
    end
  end
end
