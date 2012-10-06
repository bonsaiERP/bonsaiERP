# encoding: utf-8
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
      PgTools.set_search_path schema_name

      # Wait a second before creating data
      Unit.create_base_data
      AccountType.create_base_data
    end
  end

end
