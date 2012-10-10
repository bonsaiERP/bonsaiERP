# encoding: utf-8
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

  def change_schema(schema_name)
    connection.execute "SET search_path TO #{schema_name}"
  end
  alias :change_tenant :change_schema

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

  def execute(sql)
    connection.execute sql
  end

  # Clone public to the especified schema
  def clone_public_schema_to(schema)
    sql = get_public_schema
    sql["search_path = public"] = "search_path = #{schema}"

    connection.execute sql
  end

  def get_public_schema
    file = Rails.root.join('db', 'dump_public_schema.sh')
    create_bash_file(file, create_bash_dump_public_schema)
    sql = %x[/bin/bash #{file}]
    raise 'Error generating public schema' unless $?.success?
    File.delete(file)

    sql
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

  def create_bash_file(file, script)
    File.delete(file) if File.exists?(file)
    f = File.new(file, 'w+')
    f.write(script)
    f.chmod(0554)
    f.close
  end

  def create_bash_dump_public_schema
<<-BASH
# /bin/bash
PGPASSWORD=#{PgTools.password}
export PGPASSWORD

pg_dump --host=localhost --username=#{PgTools.username} --schema-only --schema=public #{PgTools.database}

PGPASSWORD=""
export PGPASSWORD
BASH
  end

  [:username, :database, :host, :password].each do |meth|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{meth}
        connection_config[:#{meth}]
      end
    CODE
  end

  def connection_config
    @connection_config ||= ActiveRecord::Base.connection_config
  end
  alias_method :conn_settings, :connection_config

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

  protected

    def connection
      ActiveRecord::Base.connection
    end
end
