module PgTools
  extend self

  def get_schema_name(id)
    "schema#{id}"
  end

  def public_schema?
    res = connection.execute("SHOW search_path")
    res.getvalue(0,0) === "public"
  end

  def with_schema(schema_name)
    old_search_path = connection.schema_search_path
    set_search_path(schema_name)
    connection.schema_search_path = schema_name
    result = yield

    connection.schema_search_path = old_search_path
    reset_search_path
    result
  end

  def set_search_path(schema_name)
    connection.execute "SET search_path TO #{schema_name}"
  end

  def reset_search_path
    connection.execute "SET search_path TO public"
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

  def execute(sql)
    connection.execute sql
  end

  # require 'benchmark'
  # resp = Benchmark.measure { code }
  def create_database(schema)
    create_schema schema
    reset_search_path
    set = conn_settings

    sql = `pg_dump -U #{set[:username]} #{set[:database]} -n public -s`
    sql["search_path = public"] = "search_path = #{schema}"

    connection.execute sql
  end

  def conn_settings
    ActiveRecord::Base.connection_config
  end

  protected

    def connection
      ActiveRecord::Base.connection
    end
end
