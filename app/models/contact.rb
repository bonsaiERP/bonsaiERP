# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Contact < ActiveRecord::Base
  #include Models::Account::Contact

  ########################################
  # Callbacks
  before_destroy { false }

  ########################################
  # Relationships
  has_many :transactions
  has_many :incomes,  :class_name => "Income"
  has_many :expenses,  :class_name => "Expense"
  has_many :inventory_operations
  # Account
  has_many :accounts, :as => :accountable, :autosave => true, :dependent => :destroy

  ########################################
  # Validations
  validates_presence_of    :matchcode

  validates_uniqueness_of  :matchcode

  validates_format_of     :email,  :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
  validates_format_of     :phone,  :with =>/^\d+[\d\s-]+\d$/,  :allow_blank => true
  validates_format_of     :mobile, :with =>/^\d+[\d\s-]+\d$/,  :allow_blank => true

  ########################################
  # Attributes
  attr_accessible :first_name, :last_name, :code, :organisation_name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info, :matchcode

  ########################################
  # Scopes
  scope :clients, where(:client => true)
  scope :suppliers, where(:supplier => true)

  ########################################
  # Delegates
  delegate :id, :name, :to => :account, :prefix => true

  ########################################
  # Methods

  def self.search(match)
    includes(:accounts).where("contacts.matchcode ILIKE ?", "%#{match}%")
  end

  # Finds a contact using the type
  # @param String
  def self.find_with_type(type)
    type = 'all' unless TYPES.include?(type)
    case type
    when 'Client' then Contact.clients
    when 'Supplier' then Contact.suppliers
    when 'All' then Contact.scoped
    end
  end

  def to_s
    matchcode
  end

  def total_balance_incomes
    incomes.approved[:balance, :exchange_rate].inject(0){|sum, (bal, rate)| sum += bal * rate}
  end

  def total_balance_buys
    buys.approved[:balance, :exchange_rate].inject(0){|sum, (bal, rate)| sum += bal * rate}
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

  def complete_name
    "#{first_name} #{last_name}"
  end

  alias_method :pdf_name, :complete_name

  # Creates an instance of an account with the defined currency
  def set_account_currency(cur_id)
    self.accounts.build( name: self.to_s, currency_id: cur_id) do |ac|
      ac.amount = 0
    end
  end
end
