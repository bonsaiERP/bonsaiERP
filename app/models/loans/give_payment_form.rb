# encoding: utf-8
# class for to make payments for Loans received the money goes out
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loans::GivePaymentForm < Loans::PaymentForm
  validate :valid_expense_amount, if: :account_to_is_expense?

  def create_payment
    return false  unless valid?
    res = true

    commit_or_rollback do
      res = ledger.save_ledger
      res = save_expense  if account_to_is_expense?
      res = update_loan && res
    end
  end

  def create_interest
    return false  unless valid?
    res = true

    commit_or_rollback do
      res = int_ledger.save_ledger
      res = save_expense  if account_to_is_expense?
      res = update_loan_interests && res
    end
  end

  def loan
    @loan ||= Loans::Give.find_by(id: account_id)
  end

  def ledger
    @ledger ||= begin
      AccountLedger.new(
        account_id: loan.id, account_to_id: account_to_id,
        currency: account_to_currency,
        exchange_rate: cur_exchange_rate,
        date: date, reference: reference,
        operation: 'lgpay', amount: amount,
        contact_id: loan.contact_id,
        status: get_status
      )
    end
  end

  def int_ledger
    @int_ledger ||= begin
      AccountLedger.new(
        account_id: loan.id, account_to_id: account_to_id,
        currency: account_to_currency,
        exchange_rate: cur_exchange_rate,
        date: date, reference: reference,
        operation: 'lgint', amount: amount,
        contact_id: loan.contact_id,
        status: get_status
      )
    end
  end

  private

    def account_to_is_expense?
      account_to.is_a?(Expense)
    end

    def save_expense
      account_to.amount -= amount.abs
      account_to.set_state_by_balance!

      account_to.save
    end

    def update_loan
      loan.amount -= amount_exchange
      loan.state = 'paid'  if loan.amount == 0
      loan.save
    end

    def update_loan_interests
      loan.interests = loan.interest_ledgers(true).active.sum(:amount).abs
      loan.save
    end

    def valid_expense_amount
      if amount > account_to.amount
        self.errors[:amount] = 'La cantidad es mayor que el saldo del Ingreso'
      end
    end
end
