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
    order('name desc').limit(1).pluck(:name).first
  end

  def current_year
    Date.today.year.to_s[2..4]
  end
end
