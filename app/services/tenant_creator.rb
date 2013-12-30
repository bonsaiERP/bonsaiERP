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
    return true  if schema_exists?(@tenant)

    ActiveRecord::Base.transaction do
      create_schema @tenant
      change_schema @tenant

      raise ActiveRecord::Rollback  unless clone_public_schema_to(@tenant)

      change_schema @tenant
      execute 'DROP TABLE organisations, users, links CASCADE'
      #copy_migrations

      Unit.create_base_data
      Store.create!(name: 'Almacen inicial')
      cash = Cash.new(name: 'Caja inicial', currency: organisation.currency)
      cash.save!

      Tax.create!(name: 'IVA', percentage: 13)  if organisation.country_code == 'BO'
    end

    true
  end

end
