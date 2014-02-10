class Loans::ReceiveForm < Loans::Form
  def create
    res = valid?
    commit_or_rollback do
      res = loan.save
      ledger.account_id = loan.id
      res = res && ledger.save_ledger
    end
    set_errors(loan, ledger)  unless res

    res
  end

  def loan
    @loan ||= Loans::Receive.new(
      contact_id: contact_id,
      total: total,
      amount: total,
      exchange_rate: exchange_rate,
      state: 'approved',
      date: date, due_date: due_date,
      currency: account_to_currency,
      description: description
    )
  end

  def ledger
    @ledger ||= AccountLedger.new(
        amount: loan.amount,
        account_to_id: account_to_id,
        reference: reference,
        currency: account_to_currency,
        date: date,
        operation: 'lrcre',
        contact_id: contact_id
    )
  end
end
