# encoding: utf-8
class TenantCreator

  include PgTools

  ########################################
  # Attributes
  attr_reader :tenant, :organisation

  ########################################
  # Methods
  def initialize(organisation)
    @organisation = organisation
    raise ArgumentError, 'Please select an organisation' unless @organisation.is_a?(Organisation)
    @tenant = organisation.tenant
  end

  def create_tenant
    return true if schema_exists?(tenant)

    ActiveRecord::Base.transaction do
      create_schema tenant
      clone_public_schema_to tenant
      change_schema tenant

      copy_migrations_to tenant

      Unit.create_base_data
      Store.create!(name: 'Almacen inicial')
      Cash.create!(name: 'Caja inicial', currency_id: organisation.currency_id)
    end

    true
  end

end
