# Class that stores all requried methods for form save
# 1 Saves common data Cotact details etc
# 2 Set the balance
# 3 Create ledger if direct_payment
# 4 Set item balance
# 5 Set errors for income
class Incomes::Service < Movements::Service
  alias_method :income, :movement

  private

    def save_ledger
      @ledger = direct_payment? ? build_ledger : NullLedger.new

      @ledger.save_ledger
    end

    def ledger
      @ledger ||= direct_payment? ? get_ledger : NullLedger.new
    end

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
        reference: get_reference
      )
    end

    def get_reference
      reference.present? ? reference : I18n.t('income.payment.reference', income: income)
    end

    def get_update_attributes
      attributes_class.attributes.slice(:date, :due_date, :currency, :exchange_rate, :description,:projecct_id)
      .merge(income_details_attributes: attributes_class.income_details_attributes)
    end
end
