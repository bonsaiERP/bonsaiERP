# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
 
  # GET /account_ledger 
  def index
    @ledgers = AccountLedger.pendent
  end

  # GET /account_ledgers/:id
  def show
    @ledger = present AccountLedger.find(params[:id])
  end

  def new
    @account_ledger = AccountLedger.new_money(:operation => params[:operation], :account_id => params[:account_id])
    
    redirect_to "/dashboard" unless @account_ledger
  end
  #
  # PUT /account_ledgers/:id/conciliate 
  def conciliate
    @ledger = AccountLedger.find(params[:id])

    # TODO: Move the logic and control from the model or service
    if @ledger.can_conciliate_or_null?
      case
      when params[:conciliate_commit].present?
        conciliate_account
      when
        null_account
      end
    end

    redirect_to account_ledger_path(@ledger)
  end

  # POST /account_ledgers
  def create
    @account_ledger = AccountLedger.new_money(params[:account_ledger])

    if @account_ledger.save
      flash[:notice] = "Se ha creado exitosamente la transacción."
      redirect_to @account_ledger
    else
      render :action => 'new'
    end
  end

  # DELETE /account_ledgers/:id
  def destroy
    @account_ledger = AccountLedger.find(params[:id])

    if @account_ledger.null_transaction
      flash[:notice] = "Se ha anulado la transacción correctamente."
    else
      flash[:error] = "No se pudo anular la transacción."
    end

    redirect_to @account_ledger
  end

  # POST /account_ledgers/:id/transference
  def transference
    @account = Account.find_by_id(params[:account_ledger][:account_id])
    return redirect_to "/422" unless @account

    params[:account_ledger][:operation] = "trans"
    @account_ledger = AccountLedger.new_money(params[:account_ledger])
    @account_ledger.reference = "Transferencia"

    if @account_ledger.save
      flash[:notice] = "Se ha realizado exitosamente la transferencia entre cuentas, ahora debe conciliarlas para completar la transferencia."
      redirect_to account_ledger_path(@account_ledger, :ac_id => @account_ledger.account_id)
    else
      render :action => 'new_transference'
    end
  end

private
  def conciliate_account
    con = ConciliateAccount.new(@ledger)

    if con.conciliate!
      flash[:notice] = "Se ha verificado exitosamente la transacción."
    else
      flash[:error] = "Exisitio un error al conciliar la transacción."
    end
  end

  def null_account
    if @ledger.update_attributes(nuller_id: UserSession.id, active: false, nuller_datetime: Time.zone.now)
      flash[:notice] = "Se ha anulado exitosamente la transacción."
    else
      flash[:error] = "Exisitio un error al anular la transacción."
    end
  end
end
