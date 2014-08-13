# Class that allows payments in batch
# The payment is the full amount
class BatchPaymentsController < ApplicationController

  # /batch_payments/income
  def income
    ip = Incomes::BatchPayment.new(batch_params)
    ip.make_payments

    render json: { errors: ip.errors, success: true }
  end

  # /batch_payments/expense
  def expense

  end

  private

    def batch_params
      params.slice(:ids, :account_to_id)
    end
end
