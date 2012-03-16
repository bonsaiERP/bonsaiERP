# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loan < ActiveRecord::Base
  attr_accessor :operation, :action

  self.table_name = "transactions"

  STATES   = ["draft"  , "approved" , "paid" , "due", "nulled"]
  TYPES    = ['Loanin'  , 'Loanout']

  ACTIONS  = ["edit", "approve", "payment"]
  DECIMALS = 2

  ###############################
  include Models::Loan::Base
  include Models::Loan::Approve
  include Models::Transaction::Calculations
  #include Models::Transaction::Trans
  include Models::Transaction::PayPlan

  ###############################
  
  # Relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project
  belongs_to :account, :conditions => {:accountable_type => "MoneyStore"}

  has_one  :account_ledger,  foreign_key: "transaction_id", conditions: {status: "loan_first"}, autosave: true
  has_many :account_ledgers, foreign_key: "transaction_id", conditions: {status: "none"}, dependent: :destroy, :autosave => false
  has_many :pay_plans, :foreign_key => "transaction_id", :dependent => :destroy, :order => "payment_date ASC", :autosave => true
  #has_many :payments, :foreign_key => "transaction_id"

  # Define boolean methods for states
  STATES.each do |state|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{state}?
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


  # Delegates
  delegate :symbol, :name, :to => :currency, :prefix => true, :allow_nil => true

  def is_loan?
    [Loanin, Loanout].include?(self.class)
  end

  def view_state
    states_hash[state]
  end

  def states_hash
    Hash[STATES.zip ["Proforma" , "Aprobado" , "Pagado" , "Vencido", "Anulado"]]
  end

  # Class Methods
  class << self
    def get_loans
      Loan.where(type: ["Loan", "Loanin", "Loanout"])
    end

    def get_loan(_id)
      Loan.where(type: ["Loan", "Loanin", "Loanout"], id: _id).first
    end
  end

end
