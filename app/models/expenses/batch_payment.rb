# Makes a complete payment for multiple expenses
class Expenses::BatchPayment
  attr_reader :errors, :account_id, :ids

  def initialize(data)
    @ids = data[:ids]
    @account_id = data[:account_id]
    @errors = []
  end

  def make_payments
    valid?

    expenses.each do |expense|
      make_payment(expense)
    end
  end

  def expenses
    @expenses ||= Expense.find(ids)
  rescue
    @errors << I18n.t('errors.messages.expenses.batch_payment.invalid_expenses')
    []
  end

  def account
    @account ||= Account.active.money.find_by(id: account_id)
  end

  private

    def valid?
      if expenses.any? && account.present?
        true
      else
        @errors << I18n.t('errors.messages.expenses.batch_payment.invalid_account')
        false
      end
    end

    def make_payment(expense)
      if expense.is_approved? && expense.balance > 0
        ep = Expenses::Payment.new(
          account_id: expense.id,
          account_to_id: account.id,
          date: Date.today,
          reference: I18n.t('expense.payment.reference', expense: expense.name),
          amount: expense.balance
        )

        ep.pay
      else
        @errors << I18n.t('errors.messages.expenses.batch_payment.problem', name: expense.name)
      end
    end
end
