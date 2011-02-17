# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
  def index
    @account_ledgers = AccountLedger.org.where(:account_id => params[:id]).order("date DESC")
  end
end
