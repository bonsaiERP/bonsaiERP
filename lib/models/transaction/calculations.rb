# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction::Calculations
  # quantity without discount and taxes
  def subtotal
    self.transaction_details.inject(0) {|sum, v| sum += v.total }
  end

  # Calculates the amount for taxes
  def total_taxes
    (gross_total - total_discount ) * tax_percent/100
  end

  def total_discount
    gross_total * discount/100
  end

  def total_payments
    account_ledgers.active.inject(0) {|sum, v| sum += (v.amount - v.interests_penalties) * v.exchange_rate }
  end

  def total_payments_with_interests
    account_ledgers.active.inject(0) {|sum, v| sum += v.amount_currency }
  end

  # Presents the total in currency unless the default currency
  def total_currency
    (self.total/self.exchange_rate).round(::Transaction::DECIMALS)
  end

  # Sums the total of payments
  def payments_total
    payments.active.sum(:amount)
  end

  # Sums the total amount of the payments and interests
  def payments_amount_interests_total
    payments.active.sum(:amount) + payments.active.sum(:interests_penalties)
  end

  # Returns the total value of pay plans that haven't been paid'
  def pay_plans_total
    pay_plans.unpaid.sum('amount')
  end

  # Returns the total amount to be paid for unpaid pay_plans
  def pay_plans_balance
    balance - pay_plans_total
  end

  # Updates cash based on the pay_plans
  def update_pay_plans_cash
    self.cash = ( pay_plans.size > 0 )
    self.save
  end

  def real_total
    total / exchange_rate
  end

end
