class DirectPayment < Struct.new(:service)
  delegate :reference, :transaction, :account_to_id, :date,
           to: :service

  def make_payment
    service.instance_variable_set(:@ledger, ledger)
    ledger.save_ledger
  end

private
  def ledger
    @ledger ||= AccountLedger.new(
      account_id: transaction.id, amount: transaction.total,
      account_to_id: account_to_id, date: date,
      operation: operation, status: 'approved',
      exchange_rate: 1, currency: transaction.currency, inverse: false,
      reference: get_reference
    )
  end

  def get_reference
    if transaction.is_a?(Income)
      reference.present? ? reference : I18n.t('income.payment.reference', income: transaction)
    elsif transaction.is_a?(Expense)
      reference.present? ? reference : I18n.t('expense.payment.reference', income: transaction)
    end
  end

  def operation
    if transaction.is_a?(Income)
      'payin'
    elsif transaction.is_a?(Expense)
      'payout'
    end
  end
end
