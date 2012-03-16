# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com

module Models::Loan

  class Payment
    attr_reader :loan

    def initialize(loan)
      @loan = loan
    end
  end

  module Loanin

  end

  module Loanout

  end
end
