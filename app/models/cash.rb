# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Cash < Account

  # Store accessors
  EXTRA_COLUMNS = [:email, :address, :phone].freeze
  store_accessor(:extras, *EXTRA_COLUMNS)

  # Validations
  validates :name, length: { minimum: 3 }

  # Related methods for money accounts
  include Models::Money

  def to_s
    name
  end
end

