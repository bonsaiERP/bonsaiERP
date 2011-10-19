# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Organisation < ActiveRecord::Base
  # callbacks
  before_validation :set_user, :if => :new_record?
  before_create :set_due_date
  before_create :set_preferences
  before_create :create_all_records
  before_create :create_link
  
  DATA_PATH = "db/defaults"

  attr_accessor :account_info
  attr_protected :base_accounts

  serialize :preferences, Hash
  
  # relationships
  belongs_to :org_country, :foreign_key => :country_id
  belongs_to :currency

  has_many :taxes, :class_name => "Tax", :dependent => :destroy
  has_many :units, :dependent => :destroy
  has_many :account_types, :dependent => :destroy
  has_many :accounts
  # users links
  has_many :links, :dependent => :destroy, :autosave => true
  has_many :users, :through => :links

  delegate :code, :name, :symbol, :plural, :to => :currency, :prefix => true

  # validations
  validates_associated :org_country
  validates_associated :currency

  validates_presence_of :name, :address, :country_id, :currency_id
  validates_uniqueness_of :name, :scope => :user_id

  attr_protected :user_id

  def to_s
    name
  end

  # Sets default preferences
  def set_default_preferences
    #write_attribute(:preferences, {:item_discount => 0, :general_discount => 0}) if read_attribute(:preferences).empty?
    self.preferences = {:item_discount => 0, :general_discount => 0}
    self
  end

  # Method to save preferences for callback before_create
  def set_preferences
    self.preferences = preferences.symbolize_keys
    self.preferences.merge(set_preferences_abs(preferences))
  end
  private :set_preferences

  # Updates the preferences for the organisation
  # @param Hash
  # @return [True, False]
  
  def update_preferences(options)
    options = options[:preferences].symbolize_keys
    options.merge( set_preferences_abs(options) ).merge(transform_preferences_boolean(options))
    self.preferences = options

    self.save
  end

  # Converts to abs to all numeric values
  # @params Hash
  # @return Hash
  def set_preferences_abs(options)
    [:item_discount, :general_discount].each do |par|
      options[par] = options[par].to_f.abs
    end

    options
  end

  # Method to transform checkboxes values to true
  def transform_preferences_boolean(options)
    [:open_prices].each do |par|
      options[par] = (options[par] == "1")
    end

    options
  end

  # Creates the default accounts needed to work
  def create_base_accounts
    YAML.load_file(File.join(Rails.root, "db/defaults/accounts.#{I18n.locale}.yml")).each do |data|
      ac_type_id = AccountType.find_by_account_number(data[:account_number]).id
      accounts.build(:account_type_id => ac_type_id, :name => data[:name], :currency_id => currency_id, :original_type => data[:account_number]) {|a| a.amount = 0}
    end
    self.base_accounts = true

    self.save
  end

protected

  # Creates all registers needed when an organisation is created
  def create_all_records
    #build_taxes
    build_units
    build_account_types
  end

  # Adds the default taxes for each country using a serialized value from the database
  def build_taxes
    org_country.taxes.each do |tax|
      taxes.build(tax)
    end
  end

  # creates default units the units accordins to the locale
  def build_units
    YAML.load_file(File.join(Rails.root, DATA_PATH, "units.#{I18n.locale}.yml")).each do |vals|
      units.build(vals)
    end
  end

  def build_account_types
    YAML.load_file(File.join(Rails.root, DATA_PATH, "account_types.#{I18n.locale}.yml")).each do |vals|
      account_types.build(vals) {|at| at.account_number = vals[:account_number] }
    end
  end


  # Sets the user_id, needed to define the scope of uniquenes_of :name
  def set_user
    write_attribute(:user_id, UserSession.current_user.id)
  end

  # Sets the expiry date for the organisation until ew payment
  def set_due_date
    self.due_date = 30.days.from_now.to_date
  end

  def create_link
    links.build(:rol => 'admin') {|l| 
      l.set_user_creator(UserSession.user_id)
      l.abbreviation = "GEREN"
    }
  end
end
