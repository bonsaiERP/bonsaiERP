class CreateTenant
  #@queue = :create_tenant

  def self.perform(organisation_id)
    #begin
    org = Organisation.find(organisation_id)
    #rescue
    #  return
    #end
    PgTools.create_schema org.id

    PgTools.set_search_path org.id

    org.class.transaction do
      load File.join(Rails.root, "db/schema.rb")

      org.create_records
      org.base_accounts = true
      org.save!
    end
  end
end
