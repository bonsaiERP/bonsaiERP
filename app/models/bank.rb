# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < MoneyStore

  # validations
  validates_presence_of :name, :currency
  validates :number, :uniqueness => {:scope => [:name] }, :length => {:within => 3..30}

  def to_s
    "#{name} #{number}"
  end

  private
  def set_defaults
    self.total_amount ||= 0.0
  end
end
