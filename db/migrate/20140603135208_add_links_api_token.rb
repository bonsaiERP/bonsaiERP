class AddLinksApiToken < ActiveRecord::Migration
  def up
  binding.pry
    PgTools.with_schemas only: ['common', 'public'] do
      add_column :links, :api_token, :string
      add_index :links, :api_token, unique: true
    end
  end

  def down
  binding.pry
    PgTools.with_schemas only: ['common', 'public'] do
      remove_index :links, :api_token
      remove_column :links, :api_token
    end
  end
end
