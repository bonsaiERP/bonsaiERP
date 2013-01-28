# encoding: utf-8
db_tasks = %w[db:migrate db:migrate:up db:migrate:down db:rollback db:forward]

namespace :multitenant do
  db_tasks.each do |task_name|
    desc "Run #{task_name} for each tenant"
    task task_name => %w[environment db:load_config]do
      begin
        Organisation.all.map(&:tenant).each do |tenant|
          puts "Running #{task_name} for tenant: #{tenant}"
          PgTools.scope_schema(tenant) { Rake::Task[task_name].execute }
        end
      rescue
        puts 'Creating public and common schema'
      end
    end
  end
end

namespace :bonsai do
  namespace :views do
    task incomes_view: environment do
      begin
        Organisation.all.map(&:tenant).each do |tenant|
          puts "Running #{task_name} for tenant: #{tenant}"
          PgTools.scope_schema(tenant) { Rake::Task[task_name].execute }
        end
      rescue
        puts 'Creating public and common schema'
      end
    end
  end

end

=begin
CREATE OR REPLACE VIEW incomes_view AS
SELECT name, currency, amount, contact_id, exchange_rate, project_id,
active, description, date, state, has_error, error_messages,
accounts.created_at AS created_at, accounts.updated_at AS updated_at,
balance, bill_number, gross_total, original_total, balance_inventory, 
payment_date, creator_id, approver_id, nuller_id, null_reason, 
approver_datetime, delivered, discounted, devolution
FROM accounts 
JOIN transactions ON accounts.id = transactions.account_id AND accounts.type = 'Income'

 ActiveRecord::Base.connection.table_exists? 'incomes_view'
=end

db_tasks.each do |task_name|
  Rake::Task[task_name].enhance(["multitenant:#{task_name}"])
end
