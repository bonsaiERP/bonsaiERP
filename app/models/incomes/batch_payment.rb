# Makes a complete payment for multiple incomes
class Incomes::BatchPayment
  attr_reader :errors, :account_to_id, :ids

  def initialize(data)
    @ids = data[:ids]
    @account_to_id = data[:account_to_id]
    @errors = []
  end

  def make_payments
    valid?

    incomes.each do |income|
      make_payment(income)
    end
  end

  def incomes
    @incomes ||= Income.find(ids)
  rescue
    @errors << I18n.t('errors.messages.incomes.batch_payment.invalid_incomes')
    []
  end

  def account_to
    @account_to ||= Account.active.money.find_by(id: account_to_id)
  end

  private

    def valid?
      if incomes.any? && account_to.present?
        true
      else
        @errors << I18n.t('errors.messages.incomes.batch_payment.invalid_account')
        false
      end
    end

    def make_payment(income)
      if valid_income?(income)
        ip = Incomes::Payment.new(
          account_id: income.id,
          account_to_id: account_to.id,
          date: Time.zone.now.to_date,
          reference: I18n.t('income.batch_payment.reference', income: income.name),
          amount: income.balance
        )

        ip.pay
      else
        @errors << I18n.t('errors.messages.incomes.batch_payment.problem', name: income.name)
      end
    end

    def valid_income?(income)
      !income.has_error? && income.is_approved? && income.balance > 0
    end
end
