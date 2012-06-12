# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction::Calculations
  attr_reader :transaction
    
  def initialize(transaction)
    @in = 'Income' == transaction.type
    @transaction = transaction
  end

  def in?
    !!@in
  end

  def total
  end
end
