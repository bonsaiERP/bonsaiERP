# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Contact < ActiveRecord::Base
  acts_as_org
  include Models::Account::Contact

  before_destroy { false }

  TYPES = ['Client', 'Supplier', 'Staff']

  # relations
  has_many :transactions
  has_many :incomes,  :class_name => "Transaction"
  has_many :buys,     :class_name => "Transaction"
  has_many :expenses, :class_name => "Transaction"
  # Account
  has_many :accounts, :as => :accountable, :autosave => true, :dependent => :destroy

  validates_presence_of   :first_name, :last_name, :address, :matchcode
  #validates_uniqueness_of :code, :scope => :organisation_id
  validates_uniqueness_of :matchcode, :scope => :organisation_id

  validates_format_of     :email,  :with => User.email_regexp, :allow_blank => true
  validates_format_of     :phone,  :with =>/^\d+[\d\s-]+\d$/,  :allow_blank => true
  validates_format_of     :mobile, :with =>/^\d+[\d\s-]+\d$/,  :allow_blank => true

  attr_accessible :first_name, :last_name, :code, :organisation_name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info, :matchcode
  
  # scopes
  scope :clients, where(:client => true)
  scope :suppliers, where(:supplier => true)

  # delegates
  delegate :id, :name, :to => :account, :prefix => true

  def self.search(match)
    includes(:accounts).where("contacts.matchcode LIKE ?", "%#{match}%")
  end

  # Finds a contact using the type
  # @param String
  def self.find_with_type(type)
    type = 'all' unless TYPES.include?(type)
    case type
    when 'Client' then Contact.org.clients
    when 'Supplier' then Contact.org.suppliers
    when 'All' then Contact.org
    end
  end

  def to_s
    matchcode
  end

  def account_cur(currency_id)
    accounts.find_by_currency_id(currency_id)
  end

  def show_type
    case type
    when "Client" then I18n.t("contact.client")
    when "Supplier" then I18n.t("contact.supplier")
    when "Staff" then I18n.t("contact.staff")
    end
  end

  def pdf_name
    "#{first_name} #{last_name}"
  end

end
