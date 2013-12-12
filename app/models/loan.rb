# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loan < Account
  # module for setters and getters
  extend SettersGetters
  extend Models::AccountCode

  STATES = %w(approved paid nulled)

  # Relationships
  has_one :loan_extra, dependent: :delete, autosave: true

  # Validations
  validates_presence_of :date, :due_date, :name, :contact, :contact_id
  validates :total, numericality: { greater_than: 0 }
  validate :valid_greater_due_date
  validates :state, inclusion: { in: STATES }

  # Scope

  # Delegations
  delegate(*create_accessors(*LoanExtra.get_columns), to: :loan_extra)

  class << self
    alias_method :old_new, :new

    def new(attrs = {})
      old_new do |loan|
        loan.build_loan_extra
        loan.attributes = attrs
        yield loan  if block_given?
      end
    end

  end

  alias_method :old_attributes, :attributes
  def attributes
    attrs = loan_extra.attributes
    attrs.delete(:id)
    old_attributes.merge(attrs)
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
