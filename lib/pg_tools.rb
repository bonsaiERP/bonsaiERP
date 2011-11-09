module PgTools
  extend self

  def default_search_path
    @default_search_path ||= %{"$user", public}
  end

  def set_search_path(name, include_public = true)
    path_parts = [name.to_s, ("public" if include_public)].compact
    sql = "SET search_path to #{path_parts.join(",")}"
    begin
      ActiveRecord::Base.connection.execute sql
    rescue
      false
    end
  end

  def restore_default_search_path
    set_search_path("'$user'")
  end

  def create_schema(name)
    sql = %{CREATE SCHEMA "#{name}"}
    ActiveRecord::Base.connection.execute sql
  end

  def schemas
    sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'"
    ActiveRecord::Base.connection.query(sql).flatten
  end

  # Checks if a Schema exists
  # @param[String] the name of the schema
  def schema_exists?(schema)
    begin
      restore_default_search_path
      sql = "SELECT id FROM \"#{schema}\".units LIMIT 1 OFFSET 0"
      ActiveRecord::Base.connection.execute sql
      true
    rescue
      false
    end
  end

end
