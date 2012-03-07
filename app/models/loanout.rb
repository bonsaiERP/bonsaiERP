# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loanout < Loan
  def operation
    "out"
  end

  def ledger_operation
    "out"
  end

  def reference_title
    "Egreso"
  end
end
