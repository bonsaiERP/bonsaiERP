# encoding: utf-8
module DataSupport

  def self.create_user(*args)
    args = extract_options!(args) unless args.empty?
    @user = User.create(ModelsData::user)
  end

  def self.create_and_activate_user
    user = User.create(:email => "boris@example.com", :password => "demo123", :password_confirmation => "demo123", :first_name => "Boris", :last_name => "Barroso Camberos")
    User.confirm_by_token(user.confirmation_token)
    user
  end

  # Creates data using data from the config/default directory
  def self.create_data_for(name)
    yaml = YAML::parse(File.open(Rails.root.to_s + "/config/defaults/#{name}.#{I18n.locale}.yml") ).transform
    yaml.each do |vals|
      name.singularize.capitalize.constantize.create!(vals)
    end
  end


  # Creates an organisation with all the necessary data (User, Tax, Unit)
  def self.create_organisation(name)
    user = UserSession.current_user = create_and_activate_user
    create_data_for("currencies")
    create_data_for("countries")
    country = Country.first
    currency = Currency.first
    org = Organisation.create(:name => 'ecuanime', :country_id => country.id, :currency_id => currency.id, :phone => 2745620, :mobile => '70681101', :address => 'Mallasa calle 4 Nº 71 (La Paz - Bolivia)')
    OrganisationSession.set = {:id => org.id, :name => org.name }
    org 
  end
end


module ModelsData

  def self.user
    {:first_name => "Juan", :last_name => "Perez",
    :email => "juan@example.com", :password => "demo123",
    :password_confirmation => "demo123", :phone => "12345678"}
  end
end
