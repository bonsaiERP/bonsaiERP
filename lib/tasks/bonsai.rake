# encoding: utf-8
namespace :bonsai do
  # Adds all modifications to the locales to be translated
  desc 'Updates all locales with the english version'
  task :locales => :environment do
    path = File.join(Rails.root, "config", "locales")
    en = File.join(path, "bonsai.en.yml")
    yaml_en = YAML::parse(File.open(en)).transform
    
    ["es"].each do |locale|
      locale_file = en.gsub(/bonsai.en.yml/, "bonsai.#{locale}.yml")
      yaml_locale = YAML::parse(File.open(locale_file)).transform
      final = {locale => yaml_en["en"].keep_merge(yaml_locale[locale]) }
      f = File.new(locale_file, "w+")
      f.write(final.to_yaml.gsub(/^--- \n/, ""))
      f.close

      puts %Q(locale #{locale} created)
    end
  end  

  desc 'Upates the currency rates with the latest from http://www.bcb.gob.bo/librerias/indicadores/otras/otras_imprimir.php?qdd=22&qmm=02&qaa=2011' 
  task :update_currency_rates => :environment do
    require 'open-uri'
    d = Date.today
    #month = "%02d" % d.day
    n = Nokogiri::HTML(open('http://www.bcb.gob.bo/librerias/indicadores/otras/otras_imprimir.php'))
    t = n.css('table.tablaborde').first
    dolar = t.css('tr:eq(3) td:nth-child(4)').text.to_f
    euro = t.css('tr:eq(4) td:nth-child(4)').text.to_f

    currencies = [
      {:date => d, :active => true, :currency_id => 2, :rate => dolar}, 
      {:date => d, :active => true, :currency_id => 3, :rate => euro}, 
    ]
    date = n.css('table:eq(2)>tr:eq(1)>td:eq(1)>span:eq(3)').text
    CurrencyRate.create_currencies(currencies)
    puts "The dolar #{dolar} and euro #{euro} currencies have been updated, #{date}"
  end

  desc "Updates all nulled account_ledgers with the creator"
  task :update_account_ledger_nuller => :environment do
    AccountLedger.inactive.update_all("nuller_id = creator_id")
  end

  desc "Updates account_ledgers so all have the contact"
  task :update_account_ledgers_contact_id => :environment do
    Organisation.all.each do |o|
      c = Contact.first
      if c
        AccountLedger.where(:contact_id => nil).update_all([ "contact_id=?", c.id ])
      end
    end

    puts "Puts contacts for acount_ledgers have been updated"
  end

  desc "Creates the account for all contacts that do not have account"
  task :create_contact_accounts => :environment do
    Contact.all.each do |c|
      unless c.account.present?

        c.build_account(:currency_id => 1, :name => c.to_s) {|co| 
          co.amount = 0
          co.original_type = c.class.to_s
        }
        c.save!
      end
    end
  end

  desc "Creates from zero a new installation of bonsai"
  task :create_all => :environment do
    Rake::Task["db:drop"].execute
    Rake::Task["db:migrate"].execute
  end

  desc "Creates 500 suppliers"
  task :create_suppliers => :environment do
    require 'ffaker'
    OrganisationSession.set :id => 1, :currency_id => 1
    n = 1000
    n.times do |i|
      nam = Faker::Name.name.split(" ")
      fnam, lnam = nam[0], nam[1..-1].join(" ")
      addr = [Faker::Address.street_name, Faker::Address.city ].join(" ")
      begin
        Supplier.create!(:first_name => fnam, :last_name => lnam, :address => addr, :matchcode => nam.join(" "))
      rescue
        puts nam.join(" ")
      end
    end
    puts "Created supplers"
  end

  desc "Creates 1000 clients"
  task :create_clients => :environment do
    require 'ffaker'
    OrganisationSession.set :id => 1, :currency_id => 1
    n = 1000
    n.times do |i|
      nam = Faker::Name.name.split(" ")
      fnam, lnam = nam[0], nam[1..-1].join(" ")
      addr = [Faker::Address.street_name, Faker::Address.city ].join(" ")
      Client.create!(:first_name => fnam, :last_name => lnam, :address => addr, :matchcode => nam.join(" "))
    end
    puts "Created #{n} clients"
  end

  desc "Creates the default countries"
  task :create_countries => :environment do 
    path = File.join(Rails.root, 'db/defaults/countries.yml')
    YAML.load_file(path).each do |c|
      OrgCountry.create!(c){|co| co.id = c['id'] }
    end
    puts "Countries have been created"
  end

  desc "Creates the default currencies"
  task :create_currencies => :environment do
    path = File.join(Rails.root, 'db/defaults/currencies.yml')
    YAML.load_file(path).each do |c|
      Currency.create!(c) {|cu| cu.id = c['id'] }
    end
    puts "Currencies have been created"
  end

  desc "Creates countries and currencies"
  task :create_data => :environment do
    Rake::Task["bonsai:create_currencies"].execute
    Rake::Task["bonsai:create_countries"].execute
  end

  desc "Updates all the account_ledgers to have the contact_id"
  task :add_contact_to_ledgers => :environment do
    sql = <<-EOD
      UPDATE account_ledgers set account_ledgers.contact_id = (
        SELECT transactions.contact_id FROM transactions WHERE account_ledgers.transaction_id = transactions.id
      )
    EOD
    AccountLedger.connection.execute(sql)
    sql = <<-EOD
      UPDATE account_ledgers set account_ledgers.contact_id = (
        SELECT accounts.accountable_id FROM accounts 
        WHERE 
        (accounts.accountable_type='Contact' AND accounts.id = account_ledgers.account_id)
        OR
        (accounts.accountable_type='Contact' AND accounts.id = account_ledgers.to_id)
      )
    EOD
    AccountLedger.connection.execute(sql)
  end

  desc "Creates a secuential data"
  task :account_ledger_codes => :environment do
    Organisation.all.each do |o|
      AccountLedger.connection.execute("SET @i = 0")
      AccountLedger.connection.execute("UPDATE account_ledgers SET code=(@i:=@i+1)")
      puts "Updated codes for #{o.id} - #{o}"
    end
  end

  desc "Migrates all databases"
  task :migrate => :environment do
    PgTools.reset_search_path
    ActiveRecord::Migration.verbose = verbose

    Organisation.all.each do |org|
      ActiveRecord::Base.transaction do
        if PgTools.schema_exists?(org.tenant)
          puts "migrating #{org.tenant})"
          PgTools.change_schema org.tenant
          version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
          ActiveRecord::Migrator.migrate("db/migrate/", version)
        end
      end
    end
  end

  desc "Rollbacks any migration"
  task :rollback => :environment do
    PgTools.reset_search_path
    ActiveRecord::Migration.verbose = verbose

    Organisation.all.each do |org|
      ActiveRecord::Base.transaction do
        PgTools.reset_search_path
        schema = PgTools.get_schema_name(org.id)
        if PgTools.schema_exists?(schema)
          puts "rollback #{schema})"
          PgTools.set_search_path schema
          ActiveRecord::Migrator.rollback "db/migrate/"
        end
      end
    end

  end

  task :migrate_schemas => :environment do
    PgTools.reset_search_path
    ActiveRecord::Migration.verbose = verbose

    PgTools.all_schemas.each do |schema|
      ActiveRecord::Base.transaction do
        PgTools.reset_search_path
        puts "migrating #{schema})"
        PgTools.set_search_path schema
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        ActiveRecord::Migrator.migrate("db/migrate/", version)
      end
    end
  end

  desc "Creates the base accounts for bonsai"
  task :create_accounts => :environment do
    name = "Inicial"
    ClientAccount.create!(
     :name => name, :users => 1,  :agencies => 1,
     :branding => false, :disk_space => 10, :backup => "none",
     :stored_backups => 0, :api => false, :report => false,
     :third_party_apps => true, :free_days => 0, :email => false
    ) unless ClientAccount.find_by_name(name)
    puts "Created account #{name}"

    name = "Esencial"
    ClientAccount.create!(
     :name => name, :users => 2,  :agencies => 1,
     :branding => false, :disk_space => 100,  :backup => "week",
     :stored_backups => 1, :api => true,  :report => true,
     :third_party_apps => true, :free_days => 0, :email => false
    ) unless ClientAccount.find_by_name(name)
    puts "Created account #{name}"

    name = "Básico"
    ClientAccount.create!(
     :name => name, :users => 5,  :agencies => 3,
     :branding => true, :disk_space => 200, :backup => "day",
     :stored_backups => 1, :api => true, :report => true,
     :third_party_apps => true, :free_days => 0, :email => true
    ) unless ClientAccount.find_by_name(name)
    puts "Created account #{name}"

    name = "Intermedio"
    ClientAccount.create!(
     :name => name, :users => 10,  :agencies => 3,
     :branding => true, :disk_space => 400, :backup => "day",
     :stored_backups => 7, :api => true, :report => true,
     :third_party_apps => true, :free_days => 0, :email => true
    ) unless ClientAccount.find_by_name(name)
    puts "Created account #{name}"
  end

  desc "Updates all created inventory_operation_details denormalized_data"
  task :udpate_inventory_operation_details_denormalized => :environment do
    Organisation.all.each do |org|
      PgTools.set_search_path PgTools.get_schema_name org.id
      InventoryOperation.all.each do |io|
        io.inventory_operation_details.update_all(["transaction_id = ?, operation = ?, contact_id = ?, store_id = ? ",
          io.transaction_id, io.operation, io.contact_id, io.store_id
        ])
      end
    end
    puts "Updated inventory_operation_details"
  end

  desc 'Updates the serialization from YAML to JSON'
  task update_serialization_format: :environment do
    conn = ActiveRecord::Base.connection

    conn.select_rows('select id, preferences from common.organisations').each do |o|
      res = YAML.load(o[1].to_s).to_json
      Organisation.where(id: o[0]).update_all("preferences='#{res}'")
    end

    puts 'Updated organisations'

    PgTools.all_schemas.each do |schema|
      next if schema === 'common'

      PgTools.with_schemas only: schema do
        # TransactionHistory
        conn.select_rows("select id, data from transaction_histories").each do |t|
          res = YAML.load(t[1].to_s).to_json
          begin
            TransactionHistory.where(id: t[0]).update_all("data='#{res}'")
          rescue
            TransactionHistory.where(id: t[0]).update_all("data='{}'")
          end
        end
        puts "Updated transaction_histories schema #{schema}"

        # Account
        conn.select_rows("select id, error_messages from accounts").each do |a|
          begin
            res = YAML.load(a[1].to_s).to_json
          rescue
            res = '{}'
          end
          
          Account.where(id: a[0]).update_all("error_messages='#{res}'")
        end

        puts "Updated accounts schema #{schema}"
      end
    end
  end

  desc 'Updates the incomes_status and expenses_status'
  task update_incomes_expenses_status: :environment do
    Organisation.all.each do |org|
      if PgTools.schema_exists? org.tenant
        puts org.tenant
        PgTools.change_schema org.tenant
        Contact.each do |c|
          
        end
      end
    end
  end
end

# example to export the file
# SELECT * INTO OUTFILE '/tmp/backup.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n' FROM exportar WHERE type_id=2
