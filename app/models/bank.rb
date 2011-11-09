# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < MoneyStore

  # validations
  validates_presence_of :name, :currency_id
  validates :number, :uniqueness => {:scope => [:name] }, :length => {:within => 3..30}

  attr_accessible :name, :number, :address, :phone, :website, :currency_id, :amount

  def to_s
    "#{name} #{number}"
  end

  private
  def set_defaults
    self.total_amount ||= 0.0
  end
end
