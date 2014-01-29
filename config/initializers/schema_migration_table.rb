# To correctly run migrations, because the use of HSTORE
ActiveRecord::SchemaMigration.instance_eval do
  def table_name
    'public.schema_migrations'
  end
end
