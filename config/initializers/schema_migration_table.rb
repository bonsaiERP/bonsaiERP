# To correctly run migrations
ActiveRecord::SchemaMigration.instance_eval do
  def table_name
    'public.schema_migrations'
  end
end
