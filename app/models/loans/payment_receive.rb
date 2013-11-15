# encoding: utf-8
# class for to make payments for Loans received the money goes out
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loans::PaymentReceive < Loans::Payment

  def create_payment
    return false  unless valid?
    commit_or_rollback do
      ledger.save_ledger && update_loan
    end
  end

  def create_interest
    int_ledger.save_ledger
  end

  def loan
    @loan ||= Loans::Receive.find_by(id: account_id)
  end

  def ledger
    @ledger ||= begin
      AccountLedger.new(
        account_id: loan.id, account_to_id: account_to_id, currency: currency,
        date: date, reference: reference,
        operation: 'lrpay', amount: -amount
      )
    end
  end

  def int_ledger
    @int_ledger ||= begin
      AccountLedger.new(
        account_id: loan.id, account_to_id: account_to_id, currency: currency,
        date: date, reference: reference,
        operation: 'lrint', amount: -amount
      )
    end
  end

  private

    def update_loan
      loan.amount -= amount_exchange
      loan.state = 'paid'  if loan.amount == 0
      loan.save
    end
end
