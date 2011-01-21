# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction
  acts_as_org

  attr_accessible :ref_number, :date, :contact_id,
                  :project_id, :currency_id,
                  :discount, :bill_number, :taxis_ids,
                  :description
  #validations

  # Calculates the total amout of taxes
  def total_taxes
    taxes.inject(0) {|v, sum| sum += v.rate }
  end
end
