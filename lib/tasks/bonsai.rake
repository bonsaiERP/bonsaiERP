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
        puts "Updating data from tenant #{org.tenant}"
        PgTools.change_schema org.tenant

        # Incomes
        Income.pendent.pluck(:contact_id).uniq.each do |cid|
          c = Contact.find(cid)
          incomes = IncomeQuery.new.pendent_contact_balances(cid)
          c.incomes_status = ContactBalanceStatus.new(incomes).create_balances
          c.save
        end

        # Expenses
        Expense.pendent.pluck(:contact_id).uniq.each do |cid|
          c = Contact.find(cid)
          expenses = ExpenseQuery.new.pendent_contact_balances(cid)
          c.expenses_status = ContactBalanceStatus.new(expenses).create_balances
          c.save
        end
      end
    end
  end

  desc 'Updates the schema versions'
  task update_schema_versions: :environment do
    t1 = Time.now.to_f
    file = Rails.root.join('db', 'migrations.txt')
    if File.exists?(file)
      conn = ActiveRecord::Base.connection
      PgTools.all_schemas.each do |s|
        next if s === 'common'
        puts "Updating schema: #{s}"
        conn.execute "DELETE FROM #{s}.schema_migrations"
        conn.execute "COPY #{s}.schema_migrations FROM '#{file}'"
      end
    end

    t2 = Time.now.to_f
    puts "Time: #{t2 - t1} Seconds"
  end

  desc 'removes uneeded'
  task remove_unused_tables: :environment do
    conn = ActiveRecord::Base.connection
    tables = %w(links organisations users)

    PgTools.all_schemas.each  do |schema|
      unless %w(bonsai clubv common telexfree).include?(schema)
        sql = "DROP TABLE #{tables.map {|v| "#{ schema }.#{v}" }.join(", ") };"
        conn.execute(sql)
        puts sql
      end
    end
  end

  desc 'Denormalizes the unit in items'
  task add_unit_to_items: :environment do
    PgTools.all_schemas.each  do |schema|
      unless schema === 'common'
        PgTools.change_schema schema
        puts "Updating units for items in schema #{schema}"
        Unit.all.each do |unit|
          Item.where(unit_id: unit.id).update_all(["unit_name=?, unit_symbol=?", unit.name, unit.symbol])
        end
      end
    end
  end

  desc 'Creates the demo'
  task create_demo: :environment do
    org = Organisation.find_by(tenant: 'demo')
    raise 'The demo organisation exists'  if org

    ActiveRecord::Base.transaction do
      org = Organisation.new(name: 'demo', tenant: 'demo', currency: 'BOB', country_code: 'BO',
                             phone: '591 2 775534', email: 'info@demo.com',
                             address: "Cerca de aqui\nCalle Bueno\nNo. 123")
      org.save(validate: false)


      user = User.new(email: 'demo@demo.com', password: 'demo1234', first_name: 'Demo',
                      last_name: 'Demoes', rol: 'demo')

      user.save
      user.confirm_registration
      link = user.active_links.build(
        organisation_id: org.id, tenant: org.tenant,
        rol: 'demo', master_account: true
      )
      UserSession.user = user

      link.save(validate: false)

      PgTools.create_schema 'demo'
      PgTools.clone_public_schema_to 'demo'
      PgTools.change_schema 'demo'

      PgTools.copy_migrations_to 'demo'

      Unit.create_base_data
      Store.create!(name: 'Almacen inicial')
      cash = Cash.new_cash(name: 'Caja inicial', currency: org.currency)
      cash.save!

      puts 'Demo organisation created!'
    end
  end

  def contact_data
    f, l = Faker::Name.first_name, Faker::Name.last_name
    {
      matchcode: "#{f} #{l}", first_name: f, last_name: l,
      email: Faker::Internet.email,
      phone: [Faker::PhoneNumber.phone_number][rand(2)],
      mobile: [Faker::PhoneNumber.phone_number][rand(2)],
      tax_number: Faker::Identification.ssn,
      address: [Faker::Address.street_address, Faker::Address.country].join("\n")
    }
  end

  def org_data
    f = Faker::Company.name
    {
      matchcode: f, first_name: f,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.phone_number,
      mobile: Faker::PhoneNumber.phone_number,
      tax_number: Faker::Identification.ssn,
      address: [Faker::Address.street_address, Faker::Address.country].join("\n")
    }
  end

  desc 'Creates fake data'
  task create_fake_data: :environment do
    PgTools.change_schema 'demo'
    20.times do
      l = lambda { rand(4) > 2 ? contact_data : org_data }
      c = Contact.new l.call
      if c.save
        puts c.matchcode
      else
        puts c.errors.messages
      end
    end
  end

  desc 'Create demo users'
  task create_demo_users: :environment do
    ActiveRecord::Base.transaction do
      org = Organisation.find_by(tenant: 'demo')
      user = User.new(email: 'demo1@demo.com', password: 'demo1234', first_name: 'Darma',
                      last_name: 'Demo', rol: 'demo')

      user.save
      user.confirm_registration
      link = user.active_links.build(
        organisation_id: org.id, tenant: org.tenant,
        rol: 'demo', master_account: true
      )
      UserSession.user = user

      link.save(validate: false)

      user = User.new(email: 'demo3@demo.com', password: 'demo1234', first_name: 'Anton',
                      last_name: 'Demo', rol: 'demo')

      user.save
      user.confirm_registration
      link = user.active_links.build(
        organisation_id: org.id, tenant: org.tenant,
        rol: 'demo', master_account: true
      )

      link.save(validate: false)
    end
  end

  desc 'Creates tax for all countries like bolivia'
  task create_bo_taxes: :environment do
    Organisation.where(country_code: 'BO').each do|org|
      PgTools.change_schema org.tenant
      Tax.create(name: 'IVA', percentage: 13)
    end
  end

  desc 'Updates schema_migrations before merging loan'
  task update_loan_schema_migrations: :environment do
    PgTools.all_schemas.each do |schema|
      next if  schema == 'common'
      PgTools.change_schema schema
      PgTools.execute 'ALTER TABLE account_ledgers DROP COLUMN IF EXISTS name'
      puts "Updated #{schema}"
    end

    sql = <<-SQL
INSERT INTO public.schema_migrations (version) values
('20100101101010'), ('20100324202441'), ('20100325221629'), ('20100401192000'), ('20100416193705'), ('20100421174307'), ('20100427190727'), ('20100531141109'), ('20110119140408'), ('20110201153434'), ('20110201161907'), ('20110411174426'), ('20110411182005'), ('20110411182905'), ('20111103143524'), ('20121215153208'), ('20130114144400'), ('20130114164401'), ('20130115020409'), ('20130204171801'), ('20130221151829'), ('20130325155351'), ('20130411141221'), ('20130426151609'), ('20130429120114'), ('20130510144731'), ('20130510222719'), ('20130522125737'), ('20130527202406'), ('20130618172158'), ('20130618184031'), ('20130702144114'), ('20130704130428'), ('20130715185912'), ('20130716131229'), ('20130716131801'), ('20130717190543'), ('20130911005608'), ('20131009131456'), ('20131009141203')
SQL
    PgTools.change_schema :public
    PgTools.execute 'TRUNCATE public.schema_migrations'
    PgTools.execute sql
  end

  desc 'Updates migrations'
  task update_migrations: :environment do
    PgTools.all_schemas.each do |schema|
      next if  schema == 'common'
      puts "Updating #{schema}"
      sql = <<-SQL
insert into schema_migrations (version) values ('20131211134555'),
('20131221130149'), ('20131223155017'), ('20131224080216'),
('20131224080916'), ('20131224081504'), ('20131227025934'),
('20131227032328'), ('20131229164735'), ('20140105165519');
SQL

      PgTools.change_schema schema
      PgTools.execute sql
      puts "Updated #{schema}"
    end
  end

  desc 'Copy migration numbers to schema_migrations, some tests erease schema_migrations'
  task copy_migrations: :environment do
    sql = <<-SQL
INSERT INTO public.schema_migrations (version) VALUES
#{ActiveRecord::Migrator.migrations('db/migrate').map {|v| "('#{v.version}')" }.join(', ')}
    SQL

    PgTools.execute sql
  end
end

# example to export the file
# SELECT * INTO OUTFILE '/tmp/backup.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n' FROM exportar WHERE type_id=2
