# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Cash < MoneyStore

  validates_presence_of :currency_id, :name
  validates :name, :uniqueness => {:scope => :organisation_id}

  def to_s
    "#{name} (#{currency_symbol})"
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end

end

