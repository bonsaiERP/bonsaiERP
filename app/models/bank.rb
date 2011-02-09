# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account
  # callbacks
  after_initialize :set_defaults
  after_create     :create_account_ledger

  # validations
  validates_presence_of :currency_id, :name, :number
  validates_numericality_of :total_amount, :greater_than_or_equal_to => 0, :on => :create

private
  def set_defaults
    self.total_amount ||= 0.0
  end

  # Creates the first income for the
  def create_account_ledger
    if total_amount > 0
      bl = self.account_ledgers.build(:amount => total_amount, :date => Date.today, :currency_id => currency_id)
      bl.save
    end
  end
end
