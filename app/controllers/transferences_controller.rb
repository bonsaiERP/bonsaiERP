# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransferencesController < ApplicationController
  before_filter :find_account

  # GET /transferences?account_id
  def new
    @transference = Transference.new(account_id: params[:account_id], date: Time.zone.now.to_date)
  end

  def create
    @transference = Transference.new(transference_params)

    if @transference.transfer
      redirect_to @transference.account, notice: 'Se realizo correctamente la transferencia.'
    else
      render 'new'
    end
  end

  private

    def find_account
      @account = Accounts::Query.new.money.where(id: params[:account_id]).first

      unless @account
        redirect_to :back, alert: 'Debe seleccionar una cuenta activa'
      end
    end

    def transference_params
      params[:transference][:account_id] = @account.id
      params.require(:transference).permit(:account_id, :account_to_id, :amount, :date, :exchange_rate, :reference, :verification)
    end
end
