# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentsController < ApplicationController
  # GET /payments
  # GET /payments.xml
  #def index
  #  @payments = Payment.all

  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.xml  { render :xml => @payments }
  #  end
  #end

  # GET /payments/1
  # GET /payments/1.xml
  #def show

  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.xml  { render :xml => @payment }
  #  end
  #end

  # GET /payments/new
  # GET /payments/new.xml
  def new
    @transaction = Transaction.find( params[:id] )
    @account_ledger = @transaction.new_payment
    @payment = PaymentPresenter.new(@transaction)
  end


  # POST /payments
  # POST /payments.xml
  def create
    @transaction = Transaction.find(params[:account_ledger][:transaction_id])
    params[:account_ledger][:exchange_rate] = 1 if params[:account_ledger][:exchange_rate].blank?
    
    @account_ledger = @transaction.new_payment(params[:account_ledger])

    if @transaction.save_payment
      @presenter = TransactionPresenter.new(@transaction, view_context)
      render 'create'
    else
      @payment = PaymentPresenter.new(@transaction)
      render 'new'
    end
  end

  def new_devolution
    @transaction = Transaction.find( params[:transaction_id] )
    @account_ledger = @transaction.new_devolution
    @payment = PaymentPresenter.new(@transaction)
    if @transaction.account_ledgers.pendent.any?
      render :text => "<h2 class='red'>#{I18n.t("errors.messages.payment.devolution_pendent_ledgers")}</h2>".html_safe
    else
      render "new_devolution"
    end
  end

  def devolution
    @transaction = Transaction.find(params[:account_ledger][:transaction_id])
    params[:account_ledger][:exchange_rate] = 1 if params[:account_ledger][:exchange_rate].blank?
    @account_ledger = @transaction.new_devolution(params[:account_ledger])

    if @transaction.save_devolution
      @presenter = TransactionPresenter.new(@transaction, view_context)
      @transaction = @transaction

      render 'create'
    else
      @payment = PaymentPresenter.new(@transaction)
      render 'new_devolution'
    end
  end
  # DELETE /payments/:id
  #def destroy
  #  @payment.destroy_payment
  #end

end
