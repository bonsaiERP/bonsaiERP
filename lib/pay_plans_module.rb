module PayPlansModule
  # method to create pay plans
  # @param Hash
  def create_update_pay_plans(params = {})
    @current_pay_plan = nil
    @saved_pay_plan = true

    Transaction.transaction do
      if params[:id]
        transaction.update_pay_plan()
      else
        transaction.create_pay_plan(params)
      end
      fill_pay_plans unless transaction_pay_plans.complete

      raise ActiveRecord::Rollback unless @saved_pay_plan
    end

    @current_pay_plan
  end

  def create_pay_plan(params = {})
    @current_pay_plan = pp = new_pay_plan(params)
    if @current_pay_plan.amount > pay_plans_balance
      @current_pay_plan.errors.add()
      false
    else
      pp.save
    end
  end

  # creates a new pay_plan
  def new_pay_plan(params = {})
    PayPlan.new({:transaction_id => id, :ctype => type, :currency_id => currency_id}.merge(params))
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
