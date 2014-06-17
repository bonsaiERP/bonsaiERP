namespace :bonsai do
  desc 'Updates inventory for movements using no_inventory hstore col'
  task update_movements_inventory_enabled: :environment do
    sql = <<-SQL
UPDATE accounts SET extras = CONCAT(extras::text, ',"inventory"=>"',
CASE WHEN COALESCE(extras->'no_inventory', 'false') = 'false' THEN 'true'
ELSE 'false' end, '"')::hstore
WHERE type IN ('Income', 'Expense');
    SQL

    PgTools.with_schemas except: 'common' do
      PgTools.execute sql
    end
  end

  desc 'Show env'
  task show_env: :environment do
    puts Rails.env
  end
end
