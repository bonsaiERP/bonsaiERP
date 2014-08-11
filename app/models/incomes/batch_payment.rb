# Makes a complete payment for multiple incomes
class Incomes::BatchPayment
  attr_reader :errors, :account_id, :ids

  def initialize(data)
    @ids = data[:ids]
    @account_id = data[:account_id]
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

  def account
    @account ||= Account.active.money.find_by(id: account_id)
  end

  private

    def valid?
      if incomes.empty? && account.blank?
        true
      else
        @errors << I18n.t('errors.messages.incomes.batch_payment.invalid_account')
        false
      end
    end

    def make_payment(income)
      if income.is_approved? && income.balance > 0
        ip = Incomes::Payment.new(
          account_id: income.id,
          account_to_id: account.id,
          date: Date.today,
          reference: I18n.t('incomes.batch_payment.reference', name: income.name),
          amount: income.balance
        )

        ip.pay
      else
        @errors << I18n.t('errors.messages.incomes.batch_payment.problem', name: income.name)
      end
    end
end
