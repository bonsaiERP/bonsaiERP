# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Cash < MoneyStore

  validates :name, :uniqueness => true, :length => {:minimum => 3}

  attr_accessible :name, :address, :currency_id, :amount

  def to_s
    name
  end

  private
  def set_defaults
    self.total_amount ||= 0.0
  end

end

