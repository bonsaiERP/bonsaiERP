# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  ########################################
  # Relationships
  belongs_to :income, foreign_key: :account_id, conditions: {type: 'Income'}
  belongs_to :expense, foreign_key: :account_id, conditions: {type: 'Expense'}
end
