# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account
  # callbacks
  after_initialize :set_defaults
  after_create     :create_account_ledger

  # validations
  validates_presence_of :name, :number
  validates_uniqueness_of :number, :scope => [:name, :organisation_id]

  def to_s
    "#{name} - #{number}"
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end

  # Creates the first income for the bank
  def create_account_ledger
    val = amount
    val = val.to_f
    if val > 0
      bl = self.account_ledgers.build(:amount => amount, :date => Date.today, 
                                      :currency_id => currency_id,
                                      :reference => 'NE',
                                      :description => 'Primer ingreso por creación de banco')
      bl.save
    end
  end
end
