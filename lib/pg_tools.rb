# encoding: utf-8
module PgTools
  [:username, :database, :host, :password].each do |meth|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{meth}
        connection_config[:#{meth}]
      end
    CODE
  end
  module_function :username, :database, :host, :password


  # extend self
  module_function

  def public_schema?
    res = connection.execute("SHOW search_path")
    res.getvalue(0,0) === "public"
  end

  def with_schema(schema_name)
    old_search_path = connection.schema_search_path
    set_search_path(schema_name)
    #set_schema_path(schema_name)
    connection.schema_search_path = schema_name
    result = yield

    connection.schema_search_path = old_search_path
    reset_search_path
    result
  end

  def change_schema(schema_name)
    connection.schema_search_path = [schema_name, 'public'].join(', ')
  end
  alias_method :change_tenant, :change_schema

  def set_schema_path(schema)
    ActiveRecord::Base.connection.schema_search_path = schema
  end

  def reset_search_path
    connection.execute "SET search_path TO public"
    ActiveRecord::Base.connection.reset!
  end

  def current_schema
    select_value "SHOW search_path"
  end

  def create_schema(schema_name)
    raise "#{schema_name} already exists" if schema_exists?(schema_name)

    ActiveRecord::Base.logger.info "Create #{schema_name}"
    connection.execute "CREATE SCHEMA #{schema_name}"
  end

  def copy_migrations
    res = execute "SELECT version FROM public.schema_migrations"

    values = res.to_a.map { |v| "('#{v['version']}')"}.join(",")
    execute "INSERT INTO schema_migrations (version) VALUES #{values}"
  end

  def drop_schema(schema_name)
    raise "#{schema_name} does not exists" unless schema_exists?(schema_name)

    ActiveRecord::Base.logger.info "Drop schema #{schema_name}"
    execute "DROP SCHEMA IF EXISTS #{schema_name} CASCADE"
  end

  def drop_schema_if(schema_name)
    connection.execute "DROP SCHEMA IF EXISTS #{schema_name} CASCADE"
  end

  def migrate_schema(schema_name, version = nil)
    with_schema(schema_name) do
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, version ? version.to_i : nil)
    end
  end

  def execute(sql)
    connection.execute sql
  end

  def select_rows(sql)
    connection.select_rows sql
  end

  def create_clone(tenant)
    create_schema tenant
    clone_public_schema_to tenant
  end

  # Clone public to the especified schema
  def clone_public_schema_to(schema)
    sql = get_public_schema
    sql["search_path = public, pg_catalog"] = "search_path = #{schema}, public"

    fname = "/tmp/#{SecureRandom.urlsafe_base64}.sql"
    f = File.new fname, 'w+'
    f.write sql
    f.close

    %x[PGPASSWORD='#{PgTools.password}'
    export PGPASSWORD
    psql #{PgTools.database} --username='#{PgTools.username}' --host='#{PgTools.host}' < #{fname}]

    File.delete fname

    $?.success?
  end

  def set_password_path
    %x[export PGPASSWORD=#{PgTools.password}]
  end

  def unset_password_path
    %x[export PGPASSWORD=""]
  end

  def get_public_schema
    sql = %x[#{create_bash_dump_public_schema}]
    raise 'Error generating public schema'  unless $?.success?

    sql
  end

  def create_bash_dump_public_schema
<<-BASH
# /bin/bash
PGPASSWORD='#{PgTools.password}'
export PGPASSWORD

pg_dump #{PgTools.database} --host=#{PgTools.host} --username=#{PgTools.username} --schema=public --schema-only
BASH
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

  def connection_config
    @connection_config ||= ActiveRecord::Base.connection_config
  end
  alias_method :conn_settings, :connection_config

  def schema_exists?(schema_name)
    all_schemas.include?(schema_name)
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

  def scope_schema(schema_name)
    original_search_path = connection.schema_search_path
    connection.schema_search_path = "#{schema_name}, public"

    yield
  ensure
    connection.schema_search_path = original_search_path
  end

  def all_schemas
    res = connection.select_values <<-SQL
    SELECT schema_name
    FROM information_schema.schemata
    WHERE schema_name NOT IN ('information_schema', 'public')
    AND schema_name NOT LIKE 'pg%'
    SQL
    res << 'public'

    res
  end

  def current_schema
    ActiveRecord::Base.connection.current_schema
  end

  def reset_schema_path
    ActiveRecord::Base.connection.schema_search_path = 'public'
  end

  def with_schemas(options = nil)
    options = unify_type(options, Hash) { |items| {:only => items} }

    set_options(options)
    set_options_array(options)

    schema_list = options[:only].select { |schema| options[:except].exclude? schema }

    schema_list.each do |schema|
      puts "Working on schema '#{schema}'"

      change_schema schema
      yield schema
    end
    reset_schema_path
  end

  def with_schemas_list(options = nil)
    options = unify_type(options, Hash) { |items| {:only => items} }

    set_options(options)
    set_options_array(options)

    options[:only].select { |schema| options[:except].exclude? schema }
  end

  def set_options(options)
    options[:only] = unify_type(options[:only], Array) { |item| item.nil? ? all_schemas : [item] }.map { |item| item.to_s }
    options[:except] = unify_type(options[:except], Array) { |item| item.nil? ? [] : [item] }.map { |item| item.to_s }
  end

  def set_options_array(options)
    options[:only] = unify_array_item_type(options[:only], String) { |symbol| symbol.to_s }
    options[:except] = unify_array_item_type(options[:except], String) { |symbol| symbol.to_s }
  end

  def unify_type(input, type)
    if input.is_a?(type)
      input
    else
      yield input
    end
  end

  def unify_array_item_type(input, type, &block)
    input.map do |item|
      unify_type item, type, &block
    end
  end

  def connection
    ActiveRecord::Base.connection
  end
end
