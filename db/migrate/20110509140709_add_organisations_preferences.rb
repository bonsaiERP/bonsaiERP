class AddOrganisationsPreferences < ActiveRecord::Migration
  def self.up
    add_column :organisations, :preferences, :text

    Organisation.all.each do |org|
      org.update_attribute(:preferences, {:open_prices => true } )
    end
  end

  def self.down
    remove_column :organisations, :preferences
  end
end
