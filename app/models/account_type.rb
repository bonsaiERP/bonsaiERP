# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountType < ActiveRecord::Base

  #include Models::Organisation::NewOrganisation
  
  attr_readonly :account_number

  # callbacks
  before_destroy { self.update_attribute(:active, false) ;false }

  # relationships
  has_many :accounts

  #validations
  validates_presence_of :name

  # scopes
  scope :active, where(:active => true)

  def to_s
    name
  end

  def self.create_base_data
    account_types = YAML.load_file(data_path("account_types.#{I18n.locale}.yml"))
    AccountType.create!(account_types)
  end
end
