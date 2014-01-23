class StaffAccount < Account

  # Store accessors
  EXTRA_COLUMNS = [:email, :address, :phone, :mobile].freeze
  store_accessor(:extras, *EXTRA_COLUMNS)

  # Validations
  validates :name, length: { minimum: 3 }

  # Related methods for money accounts
  include Models::Money

  def to_s
    "#{name} #{currency}"
  end
end
