# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction
  acts_as_org

  attr_accessible :contact_id, :description, :date, :ref_number
  
end
