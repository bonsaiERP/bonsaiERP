module Controllers::Contact
  def show(contact)
    case params[:tab]
    when "incomes"
      set_incomes contact
    when "buys"
      set_buys contact
    when "inventory"
      set_inventory contact
    else
      params[:tab] = "transactions"
      params[:option] = "all" unless ["all", "con", "pendent", "nulled"].include?(params[:option])
      @partial = "contacts/account_ledgers"
      @ledgers = AccountLedger.contact(contact.id)
      @ledgers = @ledgers.send(params[:option]) unless params[:option] === "all"

      @locals = {
        :ledgers => @ledgers.page(@page),
        :pendent => AccountLedger.contact(contact.account_ids).send(:pendent).size,
        :contact => contact
      }
    end
  end

  protected

  def set_incomes(contact)
    @partial = "contacts/incomes"
    params[:option] = "all" unless ["due", "draft", "approved", "paid", "inventory"].include?(params[:option])
    opt = params[:option] == "all" ? :scoped : params[:option]

    @locals = {
      :incomes => contact.incomes.send(opt).order("created_at DESC").page(@page),
      :incomes_count => contact.incomes.send(opt)
    }
  end

  def set_buys(contact)
    @partial = "contacts/buys"
    params[:option] = "all" unless ["due", "draft", "approved", "paid", "inventory"].include?(params[:option])
    opt = params[:option] == "all" ? :scoped : params[:option]

    @locals = {
      :buys => contact.buys.send(opt).order("created_at DESC").page(@page),
      :buys_count => contact.buys.send(opt)
    }
  end

  def set_inventory(contact)
    @partial = "contacts/inventory_operations"
    @locals = {
      :inventory_operations => contact.inventory_operations.includes(:store).order("created_at DESC").page(@page),
      :inventory_operations_count => contact.inventory_operations.count
    }
  end
end
