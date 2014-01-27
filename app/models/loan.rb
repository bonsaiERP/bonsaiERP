# author: Boris Barroso
# email: boriscyber@gmail.com
class Loan < Account
  # module for setters and getters
  extend SettersGetters
  extend Models::AccountCode

  include Models::History

  STATES = %w(approved paid nulled).freeze
  LOAN_TYPES = %w(Loans::Receive Loans::Give).freeze

  # Store
  extend Models::HstoreMap
  store_accessor :extras, :interests
  convert_hstore_to_decimal :interests

  # Validations
  validates_presence_of :date, :due_date, :name, :contact, :contact_id
  validates :total, numericality: { greater_than: 0 }
  validate :valid_greater_due_date
  validates :state, inclusion: { in: STATES }

  class << self
    def find(id)
      Account.where(type: LOAN_TYPES).find(id)
    end
  end

  alias_method :old_attributes, :attributes
  def attributes
    old_attributes.merge("interests" => interests)
  end

  STATES.each do |m|
    define_method :"is_#{m}?" do
      state == m
    end
  end

  private

    def valid_greater_due_date
      if due_date.present? && date.present? && due_date < date
        errors.add(:due_date, I18n.t('errors.messages.loan.due_date'))
      end
    end

end
