class AddUsersLocale < ActiveRecord::Migration
  def change
    PgTools.with_schemas only: ["common", "public"] do
      add_column :users, :locale, :string, default: "en"
    end
  end
end
