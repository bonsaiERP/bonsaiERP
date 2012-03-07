# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loanin < Loan
  def operation
    "in"
  end

  def to_s
    "Prestamo recibido #{ref_number}"
  end

  protected
  def ledger_operation
    "in"
  end

  def reference_title
    "Ingreso"
  end
end
