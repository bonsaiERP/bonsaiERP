# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loans::Form < BaseForm
  attribute :contact_id, Integer
  attribute :account_to_id, Integer
  attribute :date, Date
  attribute :due_date, Date
  attribute :total, Decimal, default: 0
  attribute :reference, String
  attribute :description, String

  attr_accessor :klass, :ledger_sign, :ledger_operation

  delegate :currency, to: :account_to, allow_nil: true
  delegate :name, to: :loan

  # validations
  validates :account_to, presence: true

  def self.new_give(attrs = {})
    loan = new(attrs)
    loan.ledger_sign = -1
    loan.ledger_operation = 'lgcre'
    loan.klass = Loans::Give
    loan
  end

  def self.new_receive(attrs = {})
    lf = new(attrs)
    lf.ledger_sign = 1
    lf.ledger_operation = 'lrcre'
    lf.klass = Loans::Receive
    lf
  end

  # Creates the loan and the ledger
  def create
    res = true
    commit_or_rollback do
      res = loan.save
      ledger.account_id = loan.id
      res = res && ledger.save_ledger
    end
    set_errors(loan, ledger)  unless res

    res
  end

  def loan
    @loan ||= klass.new(loan_attributes)
  end

  def ledger
    @ledger ||= AccountLedger.new(ledger_attributes)
  end

  def contact
    @contact ||= Contact.find_by(id: contact_id)
  end

  private

    def loan_attributes
      attributes.slice(:contact_id, :date, :due_date, :total).merge(
        currency: currency
      )
    end

    def ledger_attributes
      {
        amount: ledger_amount,
        account_to_id: account_to_id,
        reference: reference,
        currency: currency,
        date: date,
        operation: ledger_operation
      }
    end

    def account_to
      @account_to ||= Account.active.money.find_by(id: account_to_id)
    end

    def ledger_amount
      ledger_sign * total.to_f.round(2)
    end
end
