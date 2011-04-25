# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Organisation < ActiveRecord::Base
  # callbacks
  before_create :set_user
  after_create :create_all_records
  after_create :create_link
  after_create :create_account

  attr_accessor :account_info
  
  # relationships
  belongs_to :country
  belongs_to :currency

  has_many :taxes, :class_name => "Tax", :dependent => :destroy
  has_many :links
  has_many :users, :through => :links
  has_many :units, :dependent => :destroy

  delegate :code, :name, :symbol, :plural, :to => :currency, :prefix => true

  # validations
  validates_associated :country
  validates_associated :currency

  validates_presence_of :name, :address, :phone, :country_id, :currency_id
  validates_uniqueness_of :name, :scope => :user_id

  attr_protected :user_id

  def to_s
    name
  end

  def self.all
    Link.orgs
  end

protected

  # Creates all registers needed when an organisation is created
  def create_all_records
    OrganisationSession.set = { :id => self.id, :name => self.name, :curency_id => self.currency_id }
    create_taxes
    create_units
  end

  # Adds the default taxes for each country using a serialized value from the database
  def create_taxes
    country.taxes.each do |tax|
      Tax.create!(tax)
    end
  end

  # creates default units the units accordins to the locale
  def create_units
    path = File.join(Rails.root, "config", "defaults", "units.#{I18n.locale}.yml" )
    YAML::parse(File.open(path) ).transform.each do |vals|
      unit = Unit.create!(vals)
    end
  end

  # Creates the link to the user
  def create_link
    begin
      link = Link.new(:organisation_id => self.id)
      link.set_user_creator(user_id)
      link.save!
    rescue
      false
    end
  end

  # Creates the bank or CashRegister
  def create_account
    if account_info.is_a? Bank
      unless Bank.create(account_info.attributes)
        errors[:base] = "Error al crear cuenta de banco"
        raise ActiveRecord::Rollback
      end
    elsif account_info.is_a? CashRegister
      unless CashRegister.create(account_info.attributes)
        errors[:base] = "Error al crear cuenta de caja"
        raise ActiveRecord::Rollback
      end
    else
      raise ActiveRecord::Rollback
    end
  end

  # Updates the link for the user creator
  def create_link
    begin
      l = links.build(:rol => 'admin')
      l.set_user_creator(UserSession.user_id)
      l.save!
    rescue
      false
    end
  end

  # Sets the user_id, needed to define the scope of uniquenes_of :name
  def set_user
    write_attribute(:user_id, UserSession.current_user.id)
  end
end
