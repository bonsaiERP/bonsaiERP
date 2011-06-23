# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  include Models::Account::Base
  acts_as_org
  # callbacks
  before_validation :set_amount, :if => :new_record?

  attr_accessor :amount
  
  # relationships
  belongs_to :currency

  # Common validations
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validates :currency_id, :currency => true

  # delegations
  delegate :name, :symbol, :code, :plural, :to => :currency, :prefix => true

  # Creates methods to determine if is bank?, cash?
  %w[bank cash].each do |t|
    class_eval <<-CODE, __FILE__, __LINE__ +1
      def #{t}?
        self.class.to_s.downcase == "#{t}"
      end
    CODE
  end

private
  def set_amount
    self.amount ||= 0
  end
end
