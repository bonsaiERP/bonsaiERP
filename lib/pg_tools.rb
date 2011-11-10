module PgTools
  extend self

  def default_search_path
    @default_search_path ||= %{"$user", public}
  end

  def set_search_path(id, include_public = true)
    path_parts = [schema_name(id), ("public" if include_public)].compact
    sql = "SET search_path to #{path_parts.join(",")}"
    begin
      ActiveRecord::Base.connection.execute sql
    rescue
      false
    end
  end

  def restore_default_search_path
    sql = "SET search_path to #{default_search_path}"
    ActiveRecord::Base.connection.execute sql
  end

  def create_schema(id)
    sql = "CREATE SCHEMA #{schema_name(id)}"
    ActiveRecord::Base.connection.execute sql
  end

  def schemas
    sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'"
    ActiveRecord::Base.connection.query(sql).flatten
  end

  # Checks if a Schema exists
  # @param[String] the name of the schema
  def schema_exists?(id)
    begin
      restore_default_search_path
      sql = "SELECT id FROM \"#{schema_name(id)}\".units LIMIT 1 OFFSET 0"
      ActiveRecord::Base.connection.execute sql
      true
    rescue
      false
    end
  end

  def schema_name(id)
    "schema#{id}"
  end

  # Checks if the data of a schema has been created
  def created_data?(id)
    begin
      sql = "SELECT COUNT(*) FROM #{schema_name(id)}.currencies"
      res = ActiveRecord::Base.connection.execute sql
      if res.getvalue(0,0).to_i > 0
        true
      else
        false
      end
    rescue
      false
    end
  end

end
