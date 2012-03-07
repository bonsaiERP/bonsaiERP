# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loan < ActiveRecord::Base
  attr_accessor :operation, :action

  self.table_name = "transactions"

  STATES   = ["draft"  , "approved" , "paid" , "due", "inventory", "nulled"]
  TYPES    = ['Loanin'  , 'Loanout']

  ACTIONS  = ["edit", "approve"]
  DECIMALS = 2

  ###############################
  include Models::Loan::Base
  include Models::Loan::Approve
  include Models::Transaction::Calculations
  #include Models::Transaction::Trans
  include Models::Transaction::PayPlan
  include Models::Transaction::Payment

  ###############################
  
  # Relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project
  belongs_to :account, :conditions => {:accountable_type => "MoneyStore"}

  has_many :pay_plans, :foreign_key => "transaction_id"
  has_many :payments, :foreign_key => "transaction_id"
  has_many :account_ledgers, :foreign_key => "transaction_id"

  # Define boolean methods for states
  STATES.each do |state|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{state}?
        "#{state}" == state ? true : false
      end
    CODE
  end

  ACTIONS.each do |act|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_in_#{act}?
        "#{act}" == action ? true : false
      end
    CODE
  end

  # Accessible attributes
  attr_accessible :ref_number, :contact_id, :total, :project_id, :account_id

  # Delegates
  delegate :symbol, :name, :to => :currency, :prefix => true, :allow_nil => true
end
