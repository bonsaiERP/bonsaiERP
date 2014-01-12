# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Tax < ActiveRecord::Base

  has_many :accounts
  before_destroy :check_related_accounts

  # Validations
  validates :name, length: { in: 1..20 }, uniqueness: true
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than: 999 }

  include ActionView::Helpers::NumberHelper

  def to_s
    "#{name} (#{number_with_precision percentage, precision: decimals}%)"
  end

  def percentage_dec
    number_with_precision percentage, precision: decimals
  end

  private

    def decimals
      p = percentage.to_s.split('.')[1].to_i
      case
      when p == 0
        0
      when p < 10
        1
      when p > 10
        2
      end
    end

    def check_related_accounts
      accounts.empty?
    end
end
