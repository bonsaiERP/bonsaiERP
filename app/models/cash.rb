# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Cash < Account

  # Store accessors
  extend Models::HstoreMap
  EXTRA_COLUMNS = [:email, :address, :phone].freeze
  store_accessor(:extras, *EXTRA_COLUMNS)

  # Validations
  validates :name, length: { minimum: 3 }

  def pendent_ledgers
    AccountLedgers::Query.new.money(id).pendent
  end

  def get_ledgers(attrs = {})
    AccountLedgers::Query.new.money(id)
  end

  def to_s
    name
  end
end

