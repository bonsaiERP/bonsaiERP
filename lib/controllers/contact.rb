module Controllers::Contact
  def show(contact)
    case params[:tab]
    when "incomes"
      set_incomes contact
    when "buys"
    when "expenses"
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

  def set_incomes(contact)
    @partial = "contacts/incomes"
    params[:option] = "all" unless ["due", "draft", "approved", "paid", "inventory"].include?(params[:option])
    opt = params[:option] == "all" ? :scoped : params[:option]

    @locals = {
      :incomes => contact.incomes.send(opt).page(@page),
      :incomes_count => contact.incomes.send(opt)
    }
  end
end
