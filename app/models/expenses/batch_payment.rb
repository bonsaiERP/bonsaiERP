# Makes a complete payment for multiple expenses
class Expenses::BatchPayment
  attr_reader :errors, :account_to_id, :ids

  def initialize(data)
    @ids = data[:ids]
    @account_to_id = data[:account_to_id]
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

  def account_to
    @account_to ||= Account.active.money.find_by(id: account_to_id)
  end

  private

    def valid?
      if expenses.any? && account_to.present?
        true
      else
        @errors << I18n.t('errors.messages.expenses.batch_payment.invalid_account')
        false
      end
    end

    def make_payment(expense)
      if valid_expense?(expense)
        ep = Expenses::Payment.new(
          account_id: expense.id,
          account_to_id: account_to.id,
          date: Time.zone.now.to_date,
          reference: I18n.t('expense.payment.reference', expense: expense.name),
          amount: expense.balance
        )

        ep.pay
      else
        @errors << I18n.t('errors.messages.expenses.batch_payment.problem', name: expense.name)
      end
    end

    def valid_expense?(expense)
      !expense.has_error? && expense.is_approved? && expense.balance > 0
    end
end
