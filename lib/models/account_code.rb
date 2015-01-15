module Models::AccountCode
  attr_accessor :code_name

  def get_code_number
    year, num = current_year, '0001'

    if (cod = get_current_code).present?
      _, y, num = cod.split('-')
      num = '0000'  unless year == y
      num = num.next
    end

    "#{code_name}-#{year}-#{num}"
  end
  alias_method :get_ref_number, :get_code_number

  def get_current_code
    order(:id).reverse_order.limit(1).pluck(:name).first
  end

  def current_year
    Time.zone.now.year.to_s[2..4]
  end
end
