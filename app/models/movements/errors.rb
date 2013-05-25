class Movements::Errors < Struct.new(:movement)
  attr_reader :errors
  delegate :balance, :total, to: :movement

  def set_errors
    movement.has_error = false
    @errors = {balance: []}
    balance_errors

    movement.error_messages = get_errors
  end

private
  def balance_errors
    greater_balance_than_total
    negative_balance
  end

  def get_errors
    movement.has_error? ? @errors : {}
  end

  def greater_balance_than_total
    if balance > total
      movement.has_error = true
      @errors[:balance] << 'movement.balance_greater_than_total'
    end
  end

  def negative_balance
    if balance < 0
      movement.has_error = true
      @errors[:balance] << 'movement.negative_balance'
    end
  end
end

