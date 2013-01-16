# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  ########################################
  # Relationships
  belongs_to :bank, foreign_key: :account_id, conditions: {type: 'Bank'}
  belongs_to :cash, foreign_key: :account_id, conditions: {type: 'Cash'}
end
