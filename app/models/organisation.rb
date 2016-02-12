# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Organisation < ActiveRecord::Base

  DATA_PATH = "db/defaults"
  self.table_name = 'common.organisations'

  HEADER_CSS = %w(bonsai-header red-header blue-header white-header violet-header orange-header dark-header)

  ########################################
  jsonb_accessor :settings,
    inventory: :boolean,
    header_css: :string

  # Callbacks
  before_validation :set_tenant

  ########################################
  # Relationships
  has_many :links, dependent: :destroy, autosave: true
  has_many  :master_links, -> { where(master_account: true, role: "admin") },
           class_name: "Link", foreign_key: :organisation_id
  has_one  :master_account, through: :master_link, source: :user

  has_many :users, through: :links, dependent: :destroy
  #has_many :active_users, -> { where('links.active = ?', true) }, through: :links, class_name: 'Link'

  ########################################
  # Validations
  validates_presence_of   :name, :tenant
  validates :tenant, uniqueness: true, format: { with: /\A[a-z0-9]+\z/ }, length: { in: 3...15 }

  validate :valid_tenant_not_in_list
  validate :valid_header_css
  validates_email_format_of :email, if: 'email.present?', message: I18n.t('errors.messages.email')

  with_options if: :persisted? do |val|
    val.validates_presence_of :country_code, :currency
    val.validates_inclusion_of :currency, in: CURRENCIES.keys
    val.validates_inclusion_of :country_code, in: COUNTRIES.keys
  end

  ########################################
  # Delegations
  delegate :name, :to_s, to: :currency_klass, prefix: 'currency'

  ########################################
  # Methods
  def to_s
    name
  end

  def active_users
    users.where('links.active = ?', true)
  end

  def build_master_account
    self.build_master_link.build_user
    self.master_link.creator = true
  end

  def country
    Country.find country_code
  end

  def create_organisation
    self.build_master_account
    user = master_link.user

    user.email = email
    user.password = password

    unless user.valid?
      set_user_errors(user)
      return false
    end

    self.save
  end

  def dued_on?
    Date.today > due_on
  rescue
    true
  end

  def dued_with_extension?
    Date.today > due_extension_date
  rescue
    true
  end

  def due_extension_date
    due_on + 4.days
  end

  def self.test_job(a = nil)
    f = File.new Rails.root.join('test_job.txt'), 'w+'
    f.write "This job was generated in #{Time.now} with a = #{a}"
    f.close
  end

  def header_css
    settings['header_css'] || 'bonsai-header'
  end

  # Especial method that deletes the schema, users and all related stuff
  def drop_related!
    ActiveRecord::Base.transaction do
      PgTools.drop_schema_if(tenant)
      User.where(id: links.map(&:user_id)).destroy_all
      self.destroy
    end
  end

  private

    def set_user_errors(user)
      [:email, :password].each do |meth|
        user.errors[meth].each do |err|
          self.errors[meth] << err
        end
      end
    end

    # Sets the expiry date for the organisation until ew payment
    def set_due_date
      self.due_date = 30.days.from_now.to_date
    end

    def valid_tenant_not_in_list
      if INVALID_TENANTS.include?(tenant)
        self.errors[:tenant] << I18n.t('organisation.errors.tenant.list')
      end
    end

    def set_tenant
      if new_record?
        t_name = name.to_s.downcase.gsub(/[^A-Za-z]/, '')[0...15]
        self.tenant = t_name
        self.tenant = "#{t_name[0...10]}#{tenant_pad(5)}"  if Organisation.where(tenant: tenant).any?
      end
    end

    def tenant_pad(size = 5)
      SecureRandom.urlsafe_base64(32).downcase
      .gsub(/[^A-Za-z]/, '')[0...size]
    end

    def currency_klass
      @currency_klass ||= Currency.find(currency)
    end

    # Sets or checks that the header_css is valid
    def valid_header_css
      self.header_css = 'bonsai-header'  unless HEADER_CSS.include?(header_css)
    end
end
