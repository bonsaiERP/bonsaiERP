# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < MoneyStore

  # validations
  validates_presence_of :name, :currency_id
  validates :number, :uniqueness => {:scope => [:name, :organisation_id] }, :length => {:within => 3..30}

  def to_s
    "#{name} #{number} (#{currency_symbol})"
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end
end
