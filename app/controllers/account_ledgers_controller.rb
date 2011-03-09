# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
  before_filter :set_account_ledger, :only => [:show]
  
  def index
    @account_ledgers = AccountLedger.org.where(:account_id => params[:id]).order("date DESC")
  end

  def show

  end

  private
  def set_account_ledger
    @account_ledger = AccountLedger.org.find(params[:id])
  end

end
