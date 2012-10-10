# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Organisation < ActiveRecord::Base

  self.table_name = "common.organisations"

  ########################################
  # Callbacks
  before_validation :set_user, :if => :new_record?
  before_create :create_link

  DATA_PATH = "db/defaults"

  ########################################
  # Attributes
  attr_accessor :account_info
  attr_protected :base_accounts

  serialize :preferences, Hash

  attr_protected :user_id

  ########################################
  # Relationships
  belongs_to :org_country, :foreign_key => :country_id
  belongs_to :currency

  has_many :links, :dependent => :destroy, :autosave => true
  has_one  :master_link, class_name: 'Link', foreign_key: :organisation_id,
           conditions: { master_account: true, rol: 'admin' }

  has_many :users, through: :links, dependent: :destroy
  accepts_nested_attributes_for :users

  ########################################
  # Validations
  validates_presence_of   :name, :org_country, :currency, :tenant
  validates_uniqueness_of :name, :scope => :user_id
  validates :tenant, uniqueness: true, format: { with: /\A[a-z0-9]+\z/ }
  validate  :valid_tenant_not_in_list


  # Delegations
  delegate :code, :name, :symbol, :plural, :to => :currency, :prefix => true

  ########################################
  # Methods
  def to_s
    name
  end

  def build_master_account
    self.build_master_link.build_user
    self.master_link.creator = true
  end

  # Creates all registers needed when an organisation is created
  def create_records
    create_units
    create_account_types
  end

  def create_data
    PgTools.set_search_path self.id, false
    return if Currency.count > 0

    AccountType.create_base_data
    Unit.create_base_data
    Currency.create_base_data
    OrgCountry.create_base_data

    data = org.attributes
    data.delete("id")
    data.delete("user_id")

    orga = Organisation.new(data)
    orga.id = org.id
    orga.user_id = org.user_id
    orga.save!

    User.create!(user.attributes) {|u|
      u.id = user.id
      u.password = "demo123"
      u.confirmed_at = user.confirmed_at
    }
  end

  protected

    # Sets the expiry date for the organisation until ew payment
    def set_due_date
      self.due_date = 30.days.from_now.to_date
    end

    # creates default units the units accordins to the locale
    def create_units
      units = YAML.load_file(data_path("units.#{I18n.locale}.yml"))
      Unit.create!(units)
    end

    def create_account_types
      account_types = YAML.load_file(data_path("account_types.#{I18n.locale}.yml"))
      AccountType.create!(account_types)
    end

    def data_path(path = "")
      File.join(Rails.root, DATA_PATH, path)
    end

    # Sets the user_id, needed to define the scope of uniquenes_of :name
    def set_user
      write_attribute(:user_id, UserSession.current_user.id) unless user_id.present?
    end

    def create_link
      links.build(:rol => 'admin') {|l| 
        l.set_user_creator(UserSession.user_id)
      }
    end

  private
    def valid_tenant_not_in_list
      if ['public', 'common', 'demo'].include?(tenant)
        self.errors[:tenant] << I18n.t('organisation.errors.tenant.list')
      end
    end
end
