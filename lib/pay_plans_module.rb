module PayPlansModule
  # method to create pay plans
  # @param Hash
  def create_pay_plan(params = {})
    @pay_plans_list = pay_plans.unpaid
    @current_pay_plan = new_pay_plan(params)
    @pay_plans_list << @current_pay_plan
    save_pay_plans_list

    @current_pay_plan
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

        #puts "#{total_sum} :: #{balance}"
        if (total_sum + pp.amount) >= balance
          pp.amount =  balance - total_sum
          @end = true
        end

        @saved = pp.save if pp.changed?
        raise ActiveRecord::Rollback unless @saved

        total_sum += pp.amount
        i += 1
        if total_sum >= balance
          @end = true
        end
        break if @end or not @saved
      end
    end

    delete_pay_plans(@pay_plans_list, i)
  end
  
  private :save_pay_plans_list

  def delete_pay_plans(pay_plans_list, index)
    ids = pay_plans_list.slice(index, pay_plans_list.size - index).map(&:id)
    PayPlan.destroy_all(:id => ids) if ids.any?
  end

  # Sets the amount and the data for last pay_plan
  def new_pay_plan(params = {})
    repeat = params[:repeat].nil? ? not(pay_plans.unpaid.any?) : params[:repeat]
    PayPlan.new(params.merge(:transaction_id => id, :ctype => type, :repeat => repeat))
  end

  def update_pay_plan(params = {})
    @current_pay_plan = pay_plans.unpaid.find(params[:id])
    @saved_pay_plan = true
    Transaction.transaction do
      @saved_pay_plan = @current_pay_plan.update_attributes(params)
      @saved_pay_plan = create_or_update_pivot

      raise ActiveRecord::Rollback unless @saved_pay_plan
    end
  end



private
  def sort_pay_plans_list(pay_plans_list)
    pay_plans_list.sort{|a, b| a.payment_date <=> b.payment_date }
  end

  # Sums all the pay_plans until the index
  def sum_until(pay_plans_list, index)
    pay_plans_list.slice(0, index).inject(0) {|sum, pp| sum += pp.amount }
  end

  # Creates a list with the sorted pay_plans list
  def create_pay_plans_repeat_list(pay_plans_list)
    pos = pay_plans_list.index(@current_pay_plan) + 1

    sum = sum_until(pay_plans_list, pos)
    pay_plans_list = pay_plans_list.slice(0, pos)
    int_pen_per = @current_pay_plan.interests_penalties/(balance - (sum - @current_pay_plan.amount))

    if sum < balance
      actual_pay_plan = @current_pay_plan
      while_list = true
      while while_list
        actual_pay_plan = @pay_plans_list.last
        amount = actual_pay_plan.amount
        if sum + @current_pay_plan.amount > balance
          amount = balance - sum
          while_list = false
        else
          amount = @current_pay_plan.amount
        end
        #int_pen = int_pen_per * (balance - sum)

        int_pen = sum 
        sum += amount
        pp_payment_date = actual_pay_plan.payment_date + 1.month
        pp_alert_date = actual_pay_plan.payment_date - 5.days

        pay_plans_list << new_pay_plan(:payment_date => pp_payment_date, 
                                      :alert_date => pp_alert_date, :amount => amount)
      end
    end

    pay_plans_list
  end

end
