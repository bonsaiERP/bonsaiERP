class RenameLinkRolToRole < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: ['common', 'public'] do
      rename_column :links, :rol, :role
    end
  end

  def down
    PgTools.with_schemas only: ['common', 'public'] do
      rename_column :links, :role, :rol
    end
  end
end
