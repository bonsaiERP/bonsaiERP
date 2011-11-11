module PgTools
  extend self

  def get_schema_name(id)
    "schema#{id}"
  end

  def with_schema(schema_name)
    old_search_path = connection.schema_search_path
    add_schema_to_path(schema_name)
    connection.schema_search_path = schema_name
    result = yield

    connection.schema_search_path = old_search_path
    reset_search_path
    result
  end

  def add_schema_to_path(schema_name)
    connection.execute "SET search_path TO #{schema_name}"
  end

  def reset_search_path
    connection.execute "SET search_path TO #{connection.schema_search_path}"
    ActiveRecord::Base.connection.reset!
  end

  def current_search_path
    connection.select_value "SHOW search_path"
  end

  def create_schema(schema_name)
    raise "#{schema_name} already exists" if schema_exists?(schema_name)

    ActiveRecord::Base.logger.info "Create #{schema_name}"
    connection.execute "CREATE SCHEMA #{schema_name}"
  end

  def drop_schema(schema_name)
    raise "#{schema_name} does not exists" unless schema_exists?(schema_name)

    ActiveRecord::Base.logger.info "Drop schema #{schema_name}"
    connection.execute "DROP SCHEMA #{schema_name} CASCADE"
  end

  def migrate_schema(schema_name, version = nil)
    with_schema(schema_name) do
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, version ? version.to_i : nil)
    end
  end

  def load_schema_into_schema(schema_name)
    ActiveRecord::Base.logger.info "Enter schema #{schema_name}."
    with_schema(schema_name) do
      file = "#{Rails.root}/db/schema.rb"
      if File.exists?(file)
        ActiveRecord::Base.logger.info "Load the schema #{file}"
        load(file)
      else
        raise "#{file} desn't exist yet. It's possible that you just ran a migration!"
      end
    end
  end

  def schema_exists?(schema_name)
    all_schemas.include?(schema_name)
  end

  def all_schemas
    connection.select_values("SELECT * FROM pg_namespace WHERE nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
  end

  def with_all_schemas
    all_schemas.each do |schema_name|
      with_schema(schema_name) do
        yield
      end
    end
  end

  #def default_search_path
  #  @default_search_path ||= %{"$user", public}
  #end

  #def reset_search_path
  #  ActiveRecord::Base.connection.reset!
  #end

  #def set_search_path(id, include_public = true)
  #  path_parts = [schema_name(id), ("public" if include_public)].compact
  #  sql = "SET search_path to #{path_parts.join(",")}"
  #  begin
  #    ActiveRecord::Base.connection.execute sql
  #  rescue
  #    false
  #  end
  #end

  #def restore_default_search_path
  #  sql = "SET search_path to #{default_search_path}"
  #  connection.execute sql
  #end

  #def create_schema(id)
  #  sql = "CREATE SCHEMA #{schema_name(id)}"
  #  connection.execute sql
  #end

  #def schemas
  #  sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'"
  #  connection.query(sql).flatten
  #end

  ## Checks if a Schema exists
  ## @param[String] the name of the schema
  #def schema_exists?(id)
  #  begin
  #    restore_default_search_path
  #    sql = "SELECT id FROM \"#{schema_name(id)}\".units LIMIT 1 OFFSET 0"
  #    connection.execute sql
  #    true
  #  rescue
  #    false
  #  end
  #end

  #def schema_name(id)
  #  "schema#{id}"
  #end

  ## Checks if the data of a schema has been created
  #def created_data?(id)
  #  begin
  #    sql = "SELECT COUNT(*) FROM #{schema_name(id)}.currencies"
  #    res = connection.execute sql
  #    if res.getvalue(0,0).to_i > 0
  #      true
  #    else
  #      false
  #    end
  #  rescue
  #    false
  #  end
  #end

  protected

  def connection
    ActiveRecord::Base.connection
  end
end
