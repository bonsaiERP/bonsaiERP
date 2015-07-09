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
    return  if schema_exists?(tenant)
    res = true
    execute 'set search_path to public'
    #change_schema :public
    create_clone tenant

    change_schema tenant
    execute 'DROP TABLE IF EXISTS organisations, users, links CASCADE'
    change_schema tenant

    res = organisation.update_attribute(:due_on, 15.days.from_now)
    res = res && Unit.create_base_data
    res = res && Store.create!(name: 'Almacen inicial')
    res = res && Cash.create!(name: 'Caja inicial', currency: organisation.currency)

    res = res && Tax.create!(name: 'IVA', percentage: 13)  if organisation.country_code == 'BO'

    drop_schema tenant  unless res

    res != false
  end

end
