# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Organisation < ActiveRecord::Base

  self.table_name = "common.organisations"

  DATA_PATH = "db/defaults"

  ########################################
  # Attributes
  attr_readonly :tenant
  serialize :preferences, Hash

  attr_protected :user_id

  ########################################
  # Relationships

  has_many :links, :dependent => :destroy, :autosave => true
  has_one  :master_link, class_name: 'Link', foreign_key: :organisation_id, conditions: { master_account: true, rol: 'admin' }
  has_one  :master_account, through: :master_link, source: :user

  has_many :users, through: :links, dependent: :destroy
  accepts_nested_attributes_for :users

  ########################################
  # Validations
  validates_presence_of   :name, :tenant
  validates_uniqueness_of :name, :scope => :user_id
  validates :tenant, uniqueness: true, format: { with: /\A[a-z0-9]+\z/ }
  validate  :valid_tenant_not_in_list
  validates_email_format_of :email, if: 'email.present?', message: I18n.t('errors.messages.email')

  with_options if: :persisted? do |val|
    val.validates_presence_of :country_code, :currency
    val.validates_inclusion_of :currency, in: CURRENCIES.keys
    val.validates_inclusion_of :country_code, in: COUNTRIES.keys
  end

  ########################################
  # Methods
  def to_s
    name
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

  def self.test_job(a = nil)
    f = File.new Rails.root.join('test_job.txt'), 'w+'
    f.write "This job was generated in #{Time.now} with a = #{a}"
    f.close
  end

  # Especial method that deletes the schema, users and all related stuff
  def drop_related!
    ActiveRecord::Base.transaction do
      PgTools.drop_schema(tenant)
      User.where(id: links.map(&:user_id)).destroy_all
      links.destroy_all
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
    if ['www', 'public', 'common', 'demo'].include?(tenant)
      self.errors[:tenant] << I18n.t('organisation.errors.tenant.list')
    end
  end
end
