module ::Transaction::PayPlans

  MAX_PAY_PLANS_SIZE = 50
  PAY_PLANS_DATE_SEPARATION = 1.month
  DECIMALS = 2

  # method to create pay plans
  # @param Hash
  def create_pay_plan(params = {})
    set_trans(false)

    @pay_plans_list = get_pay_plans

    @current_pay_plan = new_pay_plan(params)
    @pay_plans_list << @current_pay_plan

    save_pay_plans_list
    update_transaction_payment_date

    @current_pay_plan
  end

  def update_pay_plan(params = {})
    set_trans(false)

    @pay_plans_list = get_pay_plans
    index = @pay_plans_list.index{ |p| p.id == params[:id].to_i  }

    return false unless index

    @current_pay_plan = @pay_plans_list[index]

    @current_pay_plan.attributes = params

    save_pay_plans_list
    update_transaction_payment_date

    @current_pay_plan
    
    @saved
  end

  # Destroys a pay plan
  def destroy_pay_plan(pay_plan_id = nil)
    set_trans(false)

    pay_plan_id = pay_plan_id.to_i
    @pay_plans_list = get_pay_plans

    if @pay_plans_list.size == 1 and @pay_plans_list.first.id == pay_plan_id
      destroy_last_pay_plan(pay_plan_id)
    else
      @current_pay_plan = @pay_plans_list.select {|pp| pp.id == pay_plan_id }.first

      if @pay_plans_list.last.id == @current_pay_plan.id
        pp = @pay_plans_list[@pay_plans_list.size - 2]
      else
        pp = @pay_plans_list.last
      end

      pp.amount = pp.amount + @current_pay_plan.amount
      @pay_plans_list.delete(@current_pay_plan)
      
      Transaction.transaction do
        raise ActiveRecord::Rollback unless pp.save
        @current_pay_plan.destroy
        raise ActiveRecord::Rollback unless @current_pay_plan.destroyed?
      end
      
      update_transaction_payment_date

      @current_pay_plan
    end
  end

  # Saves the list of PayPlans
  def save_pay_plans_list
    @pay_plans_list = sort_pay_plans_list(@pay_plans_list)
    @pay_plans_list = create_pay_plans_repeat_list(@pay_plans_list) if @current_pay_plan.repeat?

    @saved = true
    @end = false
    i = 0
    total_sum = 0

    Transaction.transaction do
      @saved = update_transaction_cash(false) if cash?

      while not @end
        pp = @pay_plans_list[i]

        if (total_sum + pp.amount) >= balance
          pp.amount =  balance - total_sum
          @end = true
        end

        if pp.changed?
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

    delete_pay_plans(i)
  end
  
  private :save_pay_plans_list

  def delete_pay_plans(index)
    pps = @pay_plans_list.slice(index, @pay_plans_list.size - index).compact
    pps.each {|pp| @pay_plans_list.delete(pp) } if pps.any?

    ids = pps.map(&:id)
    PayPlan.destroy_all(:id => ids) if ids.any?
  end

  # Sets the amount and the data for last pay_plan
  def new_pay_plan(params = {})
    op = self.income? ? "in" : "out"
    self.pay_plans.build(params.merge(:ctype => self.class.to_s, :transaction_id => id, :operation => op))
  end

  def update_transaction_payment_date
    @pay_plans_list = sort_pay_plans_list(@pay_plans_list)
    if @pay_plans_list.any?
      self.payment_date = @pay_plans.first.payment_date
      self.save(:validate => false)
    end
  end

  # Method used when is working on edit the items or currency_exchange_rate
  def update_transaction_pay_plans
    @pay_plans_list = get_pay_plans
    if not (balance == pay_plans_total) and @pay_plans_list.any?
      @current_pay_plan = @pay_plans_list.first
      save_pay_plans_list
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

  def delete_repeat_pay_plans_ids(pay_plans_list, ids)
    ids = ids - pay_plans_list.map(&:id).compact
    PayPlan.destroy_all(:id => ids) if ids.any?
  end

  # Creates a pay plan to complete list
  def add_new_pay_plan(total_sum)
    p_last = @pay_plans_list.last
    amt = balance - total_sum
    @pay_plans_list << new_pay_plan(:amount => balance - total_sum, :payment_date => p_last.payment_date + PAY_PLANS_DATE_SEPARATION) if amt > 0
  end

  # Creates a list with the sorted pay_plans list
  def create_pay_plans_repeat_list(pay_plans_list)
    pos = pay_plans_list.index(@current_pay_plan) + 1

    ids = pay_plans_list.map(&:id).compact if pay_plans_list.any?

    sum = sum_until(pay_plans_list, pos)
    pay_plans_list = pay_plans_list.slice(0, pos)

    delete_repeat_pay_plans_ids(pay_plans_list, ids)
    
    ids - pay_plans_list.map(&:id).compact

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
        pp_alert_date = pp_payment_date - 5.days

        pay_plans_list << new_pay_plan(:payment_date => pp_payment_date, :interests_penalties  => int_pen,
                                      :alert_date => pp_alert_date, :amount => amount, :email => @current_pay_plan.email)
      end
    end

    pay_plans_list
  end


  def update_transaction_cash(val)
    set_trans(val)
    self.cash = val
    self.save
  end

  # Returns pay_plans filtering the ones that have been added and are not stored in the database
  def get_pay_plans
    pay_plans.each{|pp| pp.destroy if pp.id.blank? }
    pay_plans.unpaid.delete_if {|pp| pp.id.blank? }
  end

  def destroy_last_pay_plan(pay_plan_id)
    saved = true
    Transaction.transaction do 
      saved = pay_plans.find(pay_plan_id).destroy.destroyed?
      raise ActiveRecord::Rollback unless saved
      saved = update_transaction_cash(true)
      raise ActiveRecord::Rollback unless saved
    end

    saved
  end

end
