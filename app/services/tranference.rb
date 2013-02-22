# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to add or update users by the admin
class Transference < BaseService
  # Attributes
  attribute :account_id, Integer
  attribute :account_to_id, Integer
  attribute :date, Date
  attribute :amount, Decimal, default: 0
  attribute :exchange_rate, Decimal, default: 1
  attribute :reference, String
  attribute :interest, Decimal, default: 0
  attribute :verification, Boolean, default: false
end
