# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loan < ActiveRecord::Base

  self.table_name = "transactions"

  STATES   = ["draft"  , "approved" , "paid" , "due", "inventory", "nulled", "discount"]
  TYPES    = ['Loanin'  , 'Loanout']
  DECIMALS = 2
  ###############################
  include Models::Transaction::Calculations
  include Models::Transaction::Trans
  include Models::Transaction::Approve
  include Models::Transaction::PayPlan
  include Models::Transaction::Payment

  ###############################
end
