namespace :bonsai do
  namespace :jsonb do
    desc "Updates all organisation settings"
    task :update_organisation => :environment do
      Oeganisation.all.each do |org|
        org.settings = org.settings_old
        org.settings = org.settings["inventory"] == "true"
      end

      sql <<-SQL
      update common.organisations set
      settings = subquery.settings
      from (select hstore_to_jsonb(settings_old) as settings
            from common.organisations) as subquery;
      SQL
      # select hstore_to_json(settings) from common.organisations;
      # update common.organisations set
      # settings = (select hstore_to_json(settings_old) from common.organisations);
    end
  end
end
