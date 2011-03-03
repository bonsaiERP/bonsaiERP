module PayPlansModule

  MAX_PAY_PLANS_SIZE = 50
  PAY_PLANS_DATE_SEPARATION = 1.month
  DECIMALS = 2

  # method to create pay plans
  # @param Hash
  def create_pay_plan(params = {})
    @pay_plans_list = pay_plans.unpaid
    @current_pay_plan = new_pay_plan(params)
    @pay_plans_list << @current_pay_plan
    save_pay_plans_list

    @current_pay_plan
  end

  def update_pay_plan(params = {})
    @pay_plans_list = pay_plans.unpaid
    index = @pay_plans_list.index{|p| p.id == params[:id].to_i}
    @current_pay_plan = @pay_plans_list[index]

    protected_attributes = PayPlan.protected_attributes.to_a.map(&:to_s)
    params.each do |k , v|
      @current_pay_plan.send(:"#{k}=", v) unless protected_attributes.include?(k.to_s)
    end

    save_pay_plans_list

    @current_pay_plan
  end

  # Destroys a pay plan
  def destroy_pay_plan(pay_plan_id)
    pay_plan_id = pay_plan_id.to_i
    @pay_plans_list = pay_plans.unpaid
    @pay_plans_list.each do |pp| 
      if pp.id == pay_plan_id
        pp.destroy_in_list = true 
        @current_pay_plan = pp
      end
    end

    save_pay_plans_list

    @pay_plans_list.select{|v| v.id }.first
  end

  # Saves the list of PayPlans
  def save_pay_plans_list
    @pay_plans_list = sort_pay_plans_list(@pay_plans_list)
    @pay_plans_list = create_pay_plans_repeat_list(@pay_plans_list) if @current_pay_plan.repeat?
    @saved = true
    @end = false
    i = 0
    total_sum = 0
    #@pay_plans_list.each_with_index{|pp, ind| puts "amt: #{pp.amount}; i: #{ind}"}

    Transaction.transaction do
      while not @end
        pp = @pay_plans_list[i]

        #puts pp.id.to_s + ' ' + pp.amount.to_s if pp == @current_pay_plan
        #puts "#{total_sum} :: #{balance}"
        if (total_sum + pp.amount) >= balance
          pp.amount =  balance - total_sum
          @end = true
        end

        if pp.destroy_in_list
          pp.destroy
          @saved = pp.destroyed?
          total_sum -= pp.amount
        elsif pp.changed?
          @saved = pp.save
        end

        raise ActiveRecord::Rollback unless @saved

        total_sum += pp.amount
        i += 1
        if total_sum >= balance
          @end = true
        end

        add_new_pay_plan(total_sum) if @pay_plans_list.size == i
        break if @end or not @saved
      end
    end

    delete_pay_plans(@pay_plans_list, i)
  end
  
  private :save_pay_plans_list

  def delete_pay_plans(pay_plans_list, index)
    ids = pay_plans_list.slice(index, pay_plans_list.size - index).map(&:id).compact
    PayPlan.destroy_all(:id => ids) if ids.any?
  end

  # Sets the amount and the data for last pay_plan
  def new_pay_plan(params = {})
    repeat = params[:repeat].nil? ? not(pay_plans.unpaid.any?) : params[:repeat]
    PayPlan.new(params.merge(:transaction_id => id, :ctype => type, :repeat => repeat))
  end


private
  def sort_pay_plans_list(pay_plans_list)
    pay_plans_list.sort{|a, b| a.payment_date <=> b.payment_date }
  end

  # Sums all the pay_plans until the index
  def sum_until(pay_plans_list, index)
    pay_plans_list.slice(0, index).inject(0) {|sum, pp| sum += pp.amount }
  end

  def delete_repeat_pay_plans_ids(pay_plans_list, ids)
    ids = ids - pay_plans_list.map(&:id).compact
    PayPlan.destroy_all(:id => ids) if ids.any?
  end

  # Creates a pay plan to complete list
  def add_new_pay_plan(total_sum)
    p_last = @pay_plans_list.last
    @pay_plans_list << new_pay_plan(:amount => balance - total_sum, :payment_date => p_last.payment_date + PAY_PLANS_DATE_SEPARATION)
  end

  # Creates a list with the sorted pay_plans list
  def create_pay_plans_repeat_list(pay_plans_list)
    pos = pay_plans_list.index(@current_pay_plan) + 1

    ids = pay_plans_list.map(&:id).compact if pay_plans_list.any?

    sum = sum_until(pay_plans_list, pos)
    pay_plans_list = pay_plans_list.slice(0, pos)

    delete_repeat_pay_plans_ids(pay_plans_list, ids)
    
    ids - pay_plans_list.map(&:id).compact
    #puts "#{ids.to_json} #{}" if ids.any?

    int_pen_per = @current_pay_plan.interests_penalties/(balance - (sum - @current_pay_plan.amount))

    if sum < balance
      actual_pay_plan = @current_pay_plan
      while_list = true
      while while_list
        actual_pay_plan = pay_plans_list.last
        amount = actual_pay_plan.amount
        if sum + @current_pay_plan.amount > balance
          amount = balance - sum
          while_list = false
        else
          amount = @current_pay_plan.amount
        end

        int_pen = ( (balance - sum) * int_pen_per ).round(DECIMALS)
        sum += amount
        pp_payment_date = actual_pay_plan.payment_date + PAY_PLANS_DATE_SEPARATION
        pp_alert_date = actual_pay_plan.payment_date - 5.days

        pay_plans_list << new_pay_plan(:payment_date => pp_payment_date, :interests_penalties  => int_pen,
                                      :alert_date => pp_alert_date, :amount => amount)
      end
    end

    pay_plans_list
  end

end
