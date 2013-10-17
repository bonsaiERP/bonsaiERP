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
      @ledger.account_id = income.id
      @ledger.operation = 'payin'

      @ledger.save_ledger
    end

    def ledger
      @ledger ||= begin

                  end
                    AccountLedger.new(
        amount: income.total,
        account_to_id: account_to_id,
        date: date,
        exchange_rate: income.exchange_rate,
        currency: movement.currency,
        inverse: false,
        reference: get_reference
      )
    end

    def get_reference
      reference.present? ? reference : I18n.t('income.payment.reference', income: income)
    end
end
