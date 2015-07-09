class Loans::LedgerInForm < BaseForm
  attribute :loan_id, Integer
  attribute :account_to_id, Integer
  attribute :amount, BigDecimal
  attribute :reference, String
  attribute :date, Date
  attribute :exchange_rate, Decimal, default: 1
  attribute :verification, Boolean, default: false

  # Validations
  validates :account_to, presence: true
  validates :account_to_id, presence: true
  validates :amount, numericality: {greater_than: 0}
  validates :reference, presence: true, length: {within: 3..300}

  # Delegates
  delegate :exchange_rate, to: :currency_exchange, prefix: 'cur'
  delegate :currency, to: :loan, prefix: true

  def loan
    @_loan ||= Loan.find_by(id: loan_id)
  end

  def create
    return false  unless valid?

    loan.class.transaction do
      loan.amount += amount * cur_exchange_rate
      loan.total += amount * cur_exchange_rate
      ledger_in.save

      loan.save && ledger_in.save_ledger
    end
  end

  def ledger_in
    @_ledger_in ||= loan.ledger_ins.build(
      account_id: loan.id,
      account_to_id: account_to_id,
      amount: get_amount,
      exchange_rate: cur_exchange_rate,
      reference: reference,
      operation: get_operation,
      date: date,
      status: get_status,
      contact_id: loan.contact_id
    )
  end

  def account_to
    @_account_to ||= Account.money.find_by(id: account_to_id)
  end

  private

    def get_amount
      if loan.is_a?(Loans::Give)
        -amount
      else
        amount
      end
    end

    def get_operation
      if loan.is_a?(Loans::Give)
        'lgcre'
      else
        'lrcre'
      end
    end

    def get_status
      verification == true ? 'pendent' : 'approved'
    end

    def currency_exchange
      @currency_exchange ||= CurrencyExchange.new(
        account: loan, account_to: account_to, exchange_rate: exchange_rate
      )
    end

end
