# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
  before_filter :check_authorization!
  #before_filter :set_account_ledger, :only => [:show, :conciliate, :destroy, :new, :personal]
 
  # GET /account_ledger 
  def index
    @account_ledgers = AccountLedger.org.where(:account_id => params[:id]).order("date DESC")
  end

  # GET /account_ledgers/:id
  def show
  end

  def new
    @account_ledger = AccountLedger.new_money(:operation => params[:operation], :account_id => params[:account_id])
  end

  # PUT /account_ledgers/:id/conciliate 
  def conciliate
    if @account_ledger.conciliate_account
      flash[:notice] = "Se ha revisado exitosamente la transacción"
    else
      flash[:error] = @account_ledger.errors[:base].join(", ")
    end
    redirect_to @account_ledger  
  end

  # Approves the account
  # PUT /account_ledgers/:id/personal
  def personal
    if @account_ledger.approve_personal(params[:account_ledger][:comment])
      flash[:notice] = "Se ha aprobado la transacción de personal"
    else
      flash[:error] = @account_ledger.errors[:base].join(", ")
    end
    redirect_to @account_ledger
  end

  # POST /account_ledgers
  def create
    @account = Account.org.find(params[:account_ledger][:account_id])
    @account_ledger = AccountLedger.new_money(params[:account_ledger])
    if @account_ledger.save
      flash[:notice] = "Se ha creado exitosamente la transacción"
      redirect_to @account_ledger
    else
      render :action => 'new'
    end
  end

  # DELETE /account_ledgers/:id
  def destroy
    @account_ledger.destroy_account_ledger
    redirect_ajax(@account_ledger)
    #unless request.xhr?
    #  if @account_ledger.destroyed?
    #    flash[:notice] = "Se ha anulado correctamente la transacción"
    #  else
    #    flash[:error] = "No es posible anular la transacción"
    #  end
    #  redirect_to @account_ledger
    #end
  end

  # GET /account_ledgers/:id/new_transference
  def new_transference
    @account             = Account.org.find(params[:id])
    @account_ledger      = @account.account_ledgers.build
    session[:account_id] = @account.id
  end

  # POST /account_ledgers/:id/transference
  def transference
    @account = Account.org.find(params[:id])
    params[:account_id] = @account.id
    @account_ledger     = @account.account_ledgers.build(params[:account_ledger])

    if @account_ledger.create_transference
      flash[:notice] = "Se ha realizado exitosamente la transferencia entre cuentas, ahora debe conciliarlas para completar la transferencia"
      redirect_to @account_ledger
    else
      render :action => 'new_transference'
    end
  end

  # Account to review
  # /account_ledgers/:id/new_review
  #def new_review
  #  @account = Account.find(params[:id])
  #  @account_ledger = AccountLedger.new(:account_id => @account.id)
  #  @account_ledger.pay_account = true
  #end

  ## Account review
  ## /account_ledgers/:id/review
  #def review
  #  @account        = Account.find(params[:id])
  #  @account_ledger = AccountLedger.new(params[:account_ledger])
  #  @account_ledger.pay_account = true
  #  @account_ledger.account_id  = @account.id

  #  if @account_ledger.save
  #    redirect_to @account_ledger
  #  else
  #    render :action => 'new_review'
  #  end
  #end


private
  def set_account_ledger
    @account_ledger = params[:id].present? ? AccountLedger.org.find(params[:id]) : AccountLedger.new(:account_id => params[:account_id], :income => params[:income], :date => Date.today)
  end

end
