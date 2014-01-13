class Movements::Errors < Struct.new(:movement)
  attr_reader :errors
  delegate :balance, :total, to: :movement

  def set_errors
    movement.has_error = false
    @errors = {}
    balance_errors
    inventory_errors

    set_error_messages
  end

  private

    def balance_errors
      greater_balance_than_total
      negative_balance
    end

    def set_error_messages
      movement.has_error = @errors.any?
      movement.error_messages = @errors
    end

    def greater_balance_than_total
      if balance > total
        @errors[:balance] ||= []
        @errors[:balance] << 'movement.balance_greater_than_total'
      end
    end

    def negative_balance
      if balance < 0
        @errors[:balance] ||= []
        @errors[:balance] << 'movement.negative_balance'
      end
    end

    def inventory_errors
      if  movement.details.any? { |v| v.balance < 0 }
        @errors[:items] ||= []
        @errors[:items] << 'movement.negative_item_balance'
      end
    end
end

