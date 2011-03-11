class Supplier < Contact
  after_initialize :set_code, :if => :new_record?

private
  def set_code
    if code.blank?
      codes = Supplier.org.order("code DESC").limit(1)
      self.code = codes.any? ? codes.first.code.next : "P-0001"
    end
  end
end
