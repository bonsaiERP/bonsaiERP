ENV["DATABASE_URL"] = "postgres://#{PgTools.username}:#{PgTools.password}@#{PgTools.host}/#{PgTools.database}"
