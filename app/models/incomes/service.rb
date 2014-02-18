# Class that stores all requried methods for form save
# 1 Saves common data Cotact details etc
# 2 Set the balance
# 3 Create ledger if direct_payment
# 4 Set item balance
# 5 Set errors for income
class Incomes::Service < Movements::Service
  alias_method :income, :movement

  def ledger
    @ledger ||= direct_payment? ? get_ledger : ::NullLedger.new
  end

  private

    def get_ledger
      AccountLedger.new(
        amount: income.total,
        account_id: income.id,
        account_to_id: account_to_id,
        date: income.date,
        exchange_rate: income.exchange_rate,
        currency: income.currency,
        inverse: false,
        operation: 'payin',
        reference: get_reference,
        contact_id: movement.contact_id
      )
    end

    def get_reference
      reference.present? ? reference : I18n.t('income.payment.reference', income: income)
    end

    def get_update_attributes
      attributes_class.income_attributes.except(:contact_id)
    end
end
