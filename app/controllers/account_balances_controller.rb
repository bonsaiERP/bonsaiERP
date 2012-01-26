class AccountBalancesController < ApplicationController

  # GET /account_balances/new
  # GET /account_balances/new.json
  def new
    unless @contact = Contact.find(params[:contact_id])
      flash[:warnig] = "El contacto que selecciono no existe"
      redirect_to dashboard_path
    end

    @account_balance = AccountBalance.new(contact_id: params[:contact_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @account_balance }
    end
  end

  # POST /account_balances
  # POST /account_balances.json
  def create
    unless @contact = Contact.find(params[:account_balance][:contact_id])
      flash[:warnig] = "El contacto que selecciono no existe"
      redirect_to dashboard_path
    end

    @account_balance = AccountBalance.new(params[:account_balance])

    respond_to do |format|
      if @account_balance.save
        format.html { redirect_to @contact, notice: "Se ha actualizado la cuenta." }
        format.json { render json: @account_balance, status: :created, location: @account_balance }
      else
        format.html { render action: "new" }
        format.json { render json: @account_balance.errors, status: :unprocessable_entity }
      end
    end
  end

end
