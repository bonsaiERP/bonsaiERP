class LoanLedgerInForm < BaseForm
  attribute :loan_id, Integer
  attribute :account_to_id, Integer
  attribute :amount, BigDecimal
  attribute :reference, String
  attribute :date, Date

  validates :account_to, presence: true
  validates :amount, numericality: {greater_than: 0}


  def loan
    @_loan ||= Loan.find(loan_id)
  end

  def create
    return false  unless valid?

    loan.class.transaction do
      loan.amount += amount
      ledger_in.save

      loan.save && ledger_in.save_ledger
    end
  end

  def ledger_in
    @_ledger_in ||= loan.ledger_ins.build(
      account_id: loan.id,
      account_to_id: account_to_id,
      amount: get_amount,
      reference: reference,
      date: date,
      contact_id: loan.contact_id
    )
  end

  def account_to
    @_account_to ||= Account.money.find(account_to_id)
  end

  private

    def get_amount
      if loan.is_a?(Loans::Give)
        -amount
      else
        amount
      end
    end

end
