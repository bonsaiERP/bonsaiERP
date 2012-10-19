# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  #include Models::Account::Money
  # callbacks
  before_validation :set_amount, :if => :new_record?

  # Attributes
  attr_accessor :amount
  
  # relationships
  belongs_to :currency
  has_one :account, :as => :accountable, :autosave => true, :dependent => :destroy

  # Common validations
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :on => :create
  validates :currency_id, :currency => true

  # delegations
  delegate :name, :symbol, :code, :plural, :to => :currency, :prefix => true
  delegate :id, :amount, :currency_id, :name, :to => :account, :prefix => true, :allow_nil => true

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
