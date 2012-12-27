# encoding: utf-8
class PaymentIncome < Payment
  # Creates the payment object
  def pay
    res = true
    ActiveRecord::Base.transaction do
      update_income
    end

    res
  end

  def income
    transaction
  end

private
  def update_income
  end
end
