# encoding: utf-8
class Supplier < Contact
  has_many :buys, :foreign_key => 'contact_id'
end
