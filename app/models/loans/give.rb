# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class for receiving loans
=begin
class Loans::Give < Loan

  extend Models::AccountCode
  self.code_name = 'PG'

  def self.new(attrs = {})
    super { |loan| loan.name = get_code_number }
  end
end
=end
