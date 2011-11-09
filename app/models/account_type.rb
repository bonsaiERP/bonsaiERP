# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountType < ActiveRecord::Base

  #include Models::Organisation::NewOrganisation
  
  attr_readonly :account_number

  # callbacks
  before_destroy { false }

  # relationships
  has_many :accounts

  #validations
  validates_presence_of :name

  def to_s
    name
  end

  def self.create_base_data
    path = File.join(Rails.root, "db/defaults", "account_types.#{I18n.locale}.yml")
    account_types = YAML.load_file(path)
    AccountType.create!(account_types)
  end
end
