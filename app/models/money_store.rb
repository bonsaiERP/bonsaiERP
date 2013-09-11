# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  ########################################
  # Relationships
  belongs_to :bank, -> { where(type: 'Bank')  } , foreign_key: :account_id
  belongs_to :cash, -> { where(type: 'Cash') }, foreign_key: :account_id


  validates_lengths_from_database
end
