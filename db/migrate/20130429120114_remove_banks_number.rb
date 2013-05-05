class RemoveBanksNumber < ActiveRecord::Migration
  def up
    Organisation.pluck(:tenant).each do |tenant|
      if PgTools.schema_exists? tenant
        Bank.includes(:money_store).each {|b| b.update_attributes!(name: "#{bank.name.strip} #{bank.number.strip}") }
      end
    end

    PgTools.with_schemas except: 'common' do
      remove_column :money_stores, :number
    end
  end

  def down
  end
end
