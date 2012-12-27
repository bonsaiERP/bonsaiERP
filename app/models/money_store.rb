# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  ########################################
  # Callbacks
  before_create :create_new_account
  after_save    :set_account_name, if: :name_changed?
  before_validation :set_amount, :if => :new_record?

  ########################################
  # Attributes
  attr_accessor :amount

  ########################################
  # Relationships
  belongs_to :currency
  has_one :account, :as => :accountable, :autosave => true, :dependent => :destroy, inverse_of: :accountable

  # Common validations
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :on => :create
  validates_presence_of :currency, :currency_id

  # delegations
  delegate :name, :symbol, :code, :plural, :to => :currency, :prefix => true
  delegate :id, :amount, :currency_id, :name, :to => :account, :prefix => true, :allow_nil => true

  # Creates methods to determine if is bank?, cash?
  %w[bank cash].each do |met|
    class_eval <<-CODE, __FILE__, __LINE__ +1
      def is_#{met}?
        self.class.to_s.downcase == "#{met}"
      end
    CODE
  end

private
  def set_amount
    self.amount ||= 0
  end

  # No need to save because of autosave
  def set_account_name
    self.account.name = self.to_s
  end

  def create_new_account
    ac = self.build_account(
      :currency_id => currency_id,
    ) do |a|
      a.original_type = self.class.to_s
      a.amount = amount
      a.name = to_s
    end
  end
end
