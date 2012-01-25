# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountBalance < ActiveRecord::Base
  belongs_to :account
  belongs_to :currency
end
