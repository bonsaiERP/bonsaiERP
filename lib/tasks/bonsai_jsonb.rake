namespace :bonsai do
  namespace :jsonb do
    desc "Updates all organisation settings"
    task :update_organisation => :environment do
      Oeganisation.all.each do |org|
        org.settings = org.settings_old
        org.settings = org.settings["inventory"] == "true"
      end
    end
  end
end
