# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class LoanExtra < ActiveRecord::Base

  #belongs_to :money_account, -> { where(type: ['Bank', 'Cash'], active: true) }, foreign_key: :account_id

  # Validations
  validates :due_date, presence: true
  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :interests, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.get_columns
    column_names.reject { |v| v == 'id' }
  end
end
