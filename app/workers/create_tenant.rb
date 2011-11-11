class CreateTenant
  #@queue = :create_tenant

  def self.perform(org_id, user_id)
    schema_name = PgTools.get_schema_name(org_id)
    return if PgTools.schema_exists?(schema_name)

    PgTools.reset_search_path
    org  = Organisation.find(org_id)
    user = User.find(user_id)

    ActiveRecord::Base.transaction do
      PgTools.create_schema schema_name
      PgTools.load_schema_into_schema schema_name
      PgTools.add_schema_to_path schema_name
      Unit.create_base_data
      AccountType.create_base_data
      Currency.create_base_data
      OrgCountry.create_base_data

      data = org.attributes
      data.delete("id")
      data.delete("user_id")

      User.create!(user.attributes) {|u|
        u.id = user.id
        u.password = "demo123"
        u.confirmed_at = user.confirmed_at
      }
      
      orga = Organisation.new(data)
      orga.id = org.id
      orga.user_id = org.user_id
      orga.save!

    end
  end

end
