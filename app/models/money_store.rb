# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  ########################################
  # Relationships
  belongs_to :account

end
