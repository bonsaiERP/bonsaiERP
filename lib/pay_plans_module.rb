module PayPlansModule
  # method to create pay plans
  # @param Hash
  def create_pay_plans(params = {})
    @current_pay_plan = nil
    @saved_pay_plan = true
    @pivot = pay_plans.pivot

    Transaction.transaction do
      @current_pay_plan = new_pay_plan(params)
      @saved_pay_plan = @current_pay_plan.save
      @saved_pay_plan = create_or_update_pivot

      raise ActiveRecord::Rollback unless @saved_pay_plan
    end

    @current_pay_plan
  end

  # Creates or udpates the pivot pay_plan
  def create_or_update_pivot
    if not @pivot and @current_pay_plan.amount == pay_plans_balance
      @current_pay_plan.pivot = true
      @current_pay_plan.save
    elsif @pivot and @pivot.amount == @current_pay_plan.amount
      @pivot.destroy
      @current_pay_plan.pivot = true
      @current_pay_plan.save
    elsif not @pivot
      @pivot = new_pay_plan(:amount => pay_plans_balance, 
                            :payment_date => @current_pay_plan.payment_date + 1.day, 
                            :alert_date => @current_pay_plan.alert_date + 1.day )
      @pivot.pivot = true
      @pivot.save
    else
      if @pivot.amount == pay_plans_balance
        @current_pay_plan.pivot = true
        @pivot.destroy
        @pivot = @current_pay_plan
        @current_pay_plan.save
      else
        @pivot.amount = @pivot.amount + pay_plans_balance
        last_pay_plan = pay_plans.unpaid.last
        @pivot.payment_date = last_pay_plan.payment_date + 1.day
        @pivot.alert_date = last_pay_plan.alert_date + 1.day
        @pivot.save
      end
    end
  end

  # creates of updates pay_plans needed to complete_pay_plans?
  def fill_pay_plans
    pp = pay_plans.unpaid.where(["payment_date > ?", @current_pay_plan.payment_date])

  end

  def complete_pay_plans?
    pay_plans_balance == 0
  end

  def update_pay_plans(pay_plan)

  end


  # returns the amount to be paid
  def get_amount
    if pay_plans.pivot
      pay_plans.pivot.amount
    else
      pay_plans_balance
    end
  end

  # creates a new pay_plan
  def new_pay_plan(params = {})
    PayPlan.new({:transaction_id => id, :ctype => type, :currency_id => currency_id, 
                :amount => get_amount(params)}.merge(params))
  end

  # Returns the amount for a new record
  def get_amount(params = {})
    if params[:amount]
      params[:amount]
    elsif @pivot
      @pivot.amount
    else
      pay_plans_balance
    end
  end

  def update_pay_plan(params = {})
    begin
      @current_pay_plan = PayPlan.find(params[:id])
      if @current_pay_plan
        @current_pay_plan.update_attributes()
      else
      end
    rescue
      false
    end
  end

end
