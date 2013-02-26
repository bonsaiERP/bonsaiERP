# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransferencesController < ApplicationController
  before_filter :find_account

  # GET /transferences?account_id
  def new
    @transference = Transference.new(account_id: params[:account_id], date: Date.today)
  end

private
  def find_account
    @account = AccountQuery.new.bank_cash.where(id: params[:account_id]).first

    unless @account
      redirect_to :back, alert: 'Debe seleccionar una cuenta activa'
    end
  end
end
