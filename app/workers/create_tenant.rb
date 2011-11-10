class CreateTenant
  @queue = :create_tenant

  def self.perform(organisation_id, user_id)
    org = Organisation.find(organisation_id)
    user = User.find(user_id)

    ActiveRecord::Base.transaction do
      PgTools.create_schema organisation_id
      PgTools.set_search_path name, false
      load File.join(Rails.root, "db/schema.rb")
    end
  end

  def self.create_base_data(org, user)
    ActiveRecord::Base.transaction do
      PgTools.set_search_path org.id, false
      AccountType.create_base_data
      Unit.create_base_data
      Currency.create_base_data
      OrgCountry.create_base_data

      data = org.attributes
      data.delete("id")
      data.delete("user_id")

      orga = Organisation.new(data)
      orga.id = org.id
      orga.user_id = org.user_id
      orga.save!

      User.create!(user.attributes) {|u|
        u.id = user.id
        u.password = "demo123"
        u.confirmed_at = user.confirmed_at
      }
    end
  end

end
