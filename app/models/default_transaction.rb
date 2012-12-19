# encoding: utf-8
class DefaultTransaction < BaseService
  attr_reader :transaction

  def initialize(trans)
    raise 'The parameter must be a Transaction class' unless trans.is_a?(Transaction)
    @transaction = trans
  end

  def create
  end

  def update(params)
  end

private
  # Sets a default payment date using PayPlan
  def update_payment_date
  end

end
