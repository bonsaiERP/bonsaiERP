# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account
  # callbacks
  after_initialize :set_defaults

  # validations
  validates_presence_of :name, :number
  validates_uniqueness_of :number, :scope => [:name, :organisation_id]

  def to_s
    "#{name} #{number} ( #{currency_name.pluralize} )"
  end

  def pendent_account_ledgers
    account_ledgers.pendent
  end

  # Prensents the total plus the account_ledgers not conciliated
  def total_pendent
    pendent_account_ledgers.sum(:amount) + total_amount
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end

end
