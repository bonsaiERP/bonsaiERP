# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
  before_filter :check_authorization!
 
  # GET /account_ledger 
  def index
    @account_ledgers = AccountLedger.org.where(:account_id => params[:id]).order("date DESC")
  end

  # GET /account_ledgers/:id
  def show
    @account_ledger = AccountLedger.org.find(params[:id])
    @account_ledger.ac_id = params[:ac_id].to_i

    if params[:ac_id].to_i === @account_ledger.to_id # @account_ledger.to_accountable_type == 'Contact'
      render 'show_contact'
    else
      render 'show'
    end
  end

  def new
    @account_ledger = AccountLedger.new_money(:operation => params[:operation], :account_id => params[:account_id])
    
    redirect_to "/dashboard" unless @account_ledger
  end

  # GET /account_ledgers/:id/new_transference
  def new_transference
    @account_ledger = AccountLedger.new_money(:operation => "trans", :account_id => params[:account_id])
    redirect_to "/dashboard" unless @account_ledger
  end
  #
  # PUT /account_ledgers/:id/conciliate 
  def conciliate
    @account_ledger = AccountLedger.org.find(params[:id])

    if @account_ledger.conciliate_account
      flash[:notice] = "Se ha revisado exitosamente la transacción"
    else
      flash[:error] = @account_ledger.errors[:base].join(", ")
    end
    redirect_to account_ledger_path(@account_ledger, :ac_id => @account_ledger.account_id)
  end

  # POST /account_ledgers
  def create
    @account = Account.org.find(params[:account_ledger][:account_id])
    @account_ledger = AccountLedger.new_money(params[:account_ledger])
    if @account_ledger.save
      flash[:notice] = "Se ha creado exitosamente la transacción"
      redirect_to account_ledger_path(@account_ledger, :ac_id => @account_ledger.account_id)
    else
      render :action => 'new'
    end
  end

  # DELETE /account_ledgers/:id
  def destroy
    @account_ledger = AccountLedger.org.find(params[:id])

    if @account_ledger.null_account
      flash[:notice] = "Se ha anulado la transacción correctamente"
    else
      flash[:error] = "No se pudo anular la transacción"
    end

    redirect_to @account_ledger.account
  end

  # POST /account_ledgers/:id/transference
  def transference
    params[:account_ledger][:operation] = "trans"
    @account_ledger = AccountLedger.new_money(params[:account_ledger])
    @account_ledger.reference = "Transferencia"

    if @account_ledger.save
      flash[:notice] = "Se ha realizado exitosamente la transferencia entre cuentas, ahora debe conciliarlas para completar la transferencia"
      redirect_to @account_ledger
    else
      render :action => 'new_transference'
    end
  end
end
