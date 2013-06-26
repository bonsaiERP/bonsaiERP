# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include ::Models::Tag

  ########################################
  # Relationships
  belongs_to :contact
  has_many :account_ledgers

  ########################################
  # Validations
  validates_presence_of :currency, :name
  validates_numericality_of :amount
  validates_inclusion_of :currency, in: CURRENCIES.keys
  validates_uniqueness_of :name

  # attribute
  serialize :error_messages, JSON

  ########################################
  # Scopes
  scope :to_pay, -> { where("amount < 0") }
  scope :to_recieve, -> { where("amount > 0") }
  scope :active, -> { where(active: true) }

  ########################################
  # Methods
  def to_s
    name
  end
end
