class UpdateMoneyStoreToHstore < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      # Bank
      execute <<-SQL
UPDATE accounts a SET extras = HSTORE('email', ms.email) || HSTORE('address', ms.address) || HSTORE('phone', ms.phone) || HSTORE('website', ms.website) FROM money_stores ms
WHERE ms.account_id = a.id AND a.type = 'Bank';
      SQL
      # Cash
      execute <<-SQL
UPDATE accounts a SET extras = HSTORE('email', ms.email) || HSTORE('address', ms.address) || HSTORE('phone', ms.phone) FROM money_stores ms WHERE ms.account_id = a.id AND a.type = 'Cash';
      SQL
    end
  end

  def down
    puts 'Nothing to change'
  end
end
