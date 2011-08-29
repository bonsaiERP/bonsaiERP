# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Staff < Contact

  attr_accessible :position

  validates_presence_of :position

private
  def set_code
    if code.blank?
      codes = Staff.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "PER-0001"
    end
  end

end

