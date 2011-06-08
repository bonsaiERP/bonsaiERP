# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerDetail < ActiveRecord::Base
  acts_as_org

  belongs_to :account
  belongs_to :account_ledger
  belongs_to :account_ledger_detail
end
