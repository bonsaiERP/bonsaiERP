# Class that stores all requried methods for form save
# 1 Saves common data Cotact details etc
# 2 Set the balance
# 3 Create ledger if direct_payment
# 4 Set item balance
# 5 Set errors for expense
class Expenses::Service < Movements::Service
  alias_method :expense, :movement

  def ledger
    @ledger ||= direct_payment? ? get_ledger : NullLedger.new
  end

  private

    def get_ledger
      AccountLedger.new(
        amount: -expense.total,
        account_id: expense.id,
        account_to_id: account_to_id,
        date: expense.date,
        exchange_rate: expense.exchange_rate,
        currency: expense.currency,
        inverse: false,
        operation: 'payout',
        reference: get_reference,
        contact_id: expense.contact_id
      )
    end

    def get_reference
      reference.present? ? reference : I18n.t('expense.payment.reference', expense: expense)
    end

    def get_update_attributes
      attributes_class.expense_attributes.except(:contact_id)
    end
end

