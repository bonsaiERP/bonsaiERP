class RemoveBanksNumber < ActiveRecord::Migration
  def up

    Organisation.pluck(:tenant).each do |tenant|
      if PgTools.schema_exists? tenant
        Bank.update_all("name=CONCAT(name, ' ', number)")
      end
    end

    PgTools.with_schemas except: 'common' do
      remove_column :money_stores, :number
    end
  end

  def down
  end
end
