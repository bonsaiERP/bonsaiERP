# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loanin < Loan
  def operation
    "in"
  end

  protected
  def ledger_operation
    "in"
  end

end
