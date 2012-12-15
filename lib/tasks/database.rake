# encoding: utf-8
db_tasks = %w[db:migrate db:migrate:up db:migrate:down db:rollback db:forward]

namespace :multitenant do
  db_tasks.each do |task_name|
    desc "Run #{task_name} for each tenant"
    task task_name => %w[environment db:load_config]do
      Organisation.all.map(&:tenant).each do |tenant|
        puts "Running #{task_name} for tenant: #{tenant}"
        PgTools.scope_schema(tenant) { Rake::Task[task_name].execute }
      end
    end
  end
end

db_tasks.each do |task_name|
  Rake::Task[task_name].enhance(["multitenant:#{task_name}"])
end
