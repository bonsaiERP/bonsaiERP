# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < MoneyStore

  include Models::Account::Base
  # validations
  validates_presence_of :name, :number, :currency_id
  validates_uniqueness_of :number, :scope => [:name, :organisation_id]

  def to_s
    "#{name} #{number} (#{currency_symbol})"
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end
end
