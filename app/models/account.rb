# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include ::Models::Tag
  include ::Models::Updater

  ########################################
  # Relationships
  belongs_to :contact
  has_many :account_ledgers

  belongs_to :approver, class_name: 'User'
  belongs_to :nuller,   class_name: 'User'
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  ########################################
  # Validations
  validates_presence_of :currency, :name
  validates_numericality_of :amount
  validates_inclusion_of :currency, in: CURRENCIES.keys
  validates_uniqueness_of :name
  validates_lengths_from_database

  # attribute
  serialize :error_messages, JSON

  ########################################
  # Scopes
  scope :to_pay, -> { where('amount < 0') }
  scope :to_recieve, -> { where('amount > 0') }
  scope :active, -> { where(active: true) }
  scope :money, -> { where(type: ['Bank', 'Cash']) }

  delegate :name, :code, :symbol, to: :curr, prefix: true

  ########################################
  # Methods
  def to_s
    name
  end

  def curr
    @curr ||= Currency.find(currency)
  end
end
