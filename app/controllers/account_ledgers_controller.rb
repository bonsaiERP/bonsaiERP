# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
  before_filter :set_account_ledger, :only => [:show, :conciliate, :destroy]
 
  # GET /account_ledger 
  def index
    @account_ledgers = AccountLedger.org.where(:account_id => params[:id]).order("date DESC")
  end

  # GET /account_ledgers/:id
  def show
  end

  # PUT /account_ledgers/:i.more 
  def conciliate
    if @account_ledger.conciliate_account
      redirect_to @account_ledger, :notice => "Se ha conciliado exitosamente la transacción"
    end
  end

  def destroy
    @account_ledger.destroy
    redirect_ajax @account_ledger
  end

  private
  def set_account_ledger
    @account_ledger = AccountLedger.org.find(params[:id])
  end

end
