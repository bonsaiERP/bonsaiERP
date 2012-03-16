# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::AccountLedger

  def set_loan(loan)
    @loan = case
    when loan.is_a?(Loanin)  then Loanin.new(loan)
    when loan.is_a?(Loanout) then Loanout.new(loan)
    end
  end
  class Loan
    attr_accessor :loan
  
    def initialize(loan)
      @loan = loan
      set_loan_class
    end
  end

  class Loanin

  end
end
