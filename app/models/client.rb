# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Client < Contact
  #after_initialize :set_code, :if => :new_record?

private
  def set_code
    if code.blank?
      codes = Client.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "C-0001"
    end
  end
end
