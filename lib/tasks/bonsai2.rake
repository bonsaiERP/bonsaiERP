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

  desc 'Sets the token for links'
  task generate_tokens: :environment do
    Link.where(api_token: nil).each do |link|
      unless link.update(api_token: SecureRandom.urlsafe_base64(32))
        puts "Error updating API token for link #{link.id}"
      end
    end
  end
end
