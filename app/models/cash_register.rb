# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CashRegister < Account
  after_initialize :set_defaults

  validates_presence_of :currency_id, :name, :address
  validates :name, :uniqueness => {:scope => :organisation_id}

  def to_s
    name
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end
end

