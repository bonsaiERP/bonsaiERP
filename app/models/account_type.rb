# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountType < ActiveRecord::Base

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
    data = YAML.load_file(path)
    AccountType.create!(data)
  end
end
