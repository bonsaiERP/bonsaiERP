# encoding: utf-8
class TenantCreator

  include PgTools

  ########################################
  # Attributes
  attr_reader :tenant

  ########################################
  # Methods
  def initialize(tenant)
    @tenant = tenant.gsub(/[^a-z0-9]/, '')
    raise ArgumentError, 'Please set a correct tenant parameter' unless @tenant.present?
  end

  def create_tenant
    return true if schema_exists?(tenant)

    ActiveRecord::Base.transaction do
      create_schema tenant
      clone_public_schema_to tenant
      change_schema tenant

      Unit.create_base_data
      AccountType.create_base_data
    end

    true
  end

end
