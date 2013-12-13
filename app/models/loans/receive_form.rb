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
      state: 'approved',
      date: date, due_date: due_date,
      currency: currency
    )
  end

  def ledger
    @ledger ||= AccountLedger.new(
        amount: loan.amount,
        account_to_id: account_to_id,
        reference: reference,
        currency: currency,
        date: date,
        operation: 'lrcre'
    )
  end
end
