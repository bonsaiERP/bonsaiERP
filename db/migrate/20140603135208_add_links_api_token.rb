class AddLinksApiToken < ActiveRecord::Migration
  def up
    PgTools.with_schemas :common do
      add_column :links, :api_token, :string
      add_index :links, :api_token, unique: true
    end
  end

  def down
    PgTools.with_schemas :common do
      remove_index :links, :api_token
      remove_column :links, :api_token
    end
  end
end
