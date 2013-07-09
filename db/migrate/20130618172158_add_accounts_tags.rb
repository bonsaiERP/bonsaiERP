class AddAccountsTags < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      execute "ALTER TABLE accounts ADD COLUMN tag_ids integer[] DEFAULT '{}'"

      execute "CREATE INDEX index_accounts_on_tag_ids ON accounts USING GIN(tag_ids)"
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      execute "ALTER TABLE accounts DROP COLUMN tag_ids"
    end
  end
end
