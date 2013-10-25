# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loan < Account
  # module for setters and getters
  extend SettersGetters

  # Relationships
  has_one :loan_extra, dependent: :delete, autosave: true

  # Validations
  validates_presence_of :date, :name, :contact
  validates :total, numericality: { greater_than: 0 }

  # Delegations
  delegate(*create_accessors(*LoanExtra.get_columns), to: :loan_extra)

  class << self
    alias_method :old_new, :new

    def new(attrs = {})
      old_new do |loan|
        loan.build_loan_extra
        loan.attributes = attrs
        loan.amount = loan.total # if loan.new_record?
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
end
