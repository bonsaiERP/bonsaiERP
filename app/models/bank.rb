# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account

  # Store accessors
  extend Models::HstoreMap
  EXTRA_COLUMNS = [:email, :address, :phone, :website].freeze
  store_accessor(:extras, *EXTRA_COLUMNS)

  # can't use Bank.stored_attributes methods[:extras]
  alias_method :old_attributes, :attributes
  def attributes
    old_attributes.merge(
      Hash[EXTRA_COLUMNS.map { |k| [k.to_s, send(k)] }]
    )
  end

  # Related methods for money accounts
  include Models::Money

  def to_s
    name
  end

  private

    def set_defaults
      self.total_amount ||= 0.0
    end
end
