# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Staff < Contact

  default_scope -> { where(staff: true) }

  validates_presence_of :position, :first_name, :last_name
end
