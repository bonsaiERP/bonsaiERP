# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgersController < ApplicationController
  include Controllers::Print

  before_action :set_ledger, only: [:conciliate, :null, :update]

  # GET /account_ledger
  def index
    if params[:pendent]
      @title = "Transacciones no pendientes"
      @ledgers = AccountLedger.pendent.includes(:account, :account_to, :contact)
    else
      @title = "Transacciones"
      @ledgers = AccountLedgers::Query.new.search(params[:search])
      @ledgers = AccountLedger.all if @ledgers.empty?
    end

    @ledgers = @ledgers.includes(:creator, :updater, :approver, :nuller).order(:date, :id).reverse_order.page(@page)
  end

  # GET /account_ledgers/:id
  def show
    @ledger = present AccountLedger.find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show.print', "recibo-#{@ledger}"  unless params[:debug] }
    end
  end

  # PATCH /account_ledgers/:id
  # update the reference
  def update
    if @account_ledger.update_attributes(reference: params[:reference])
      al = @account_ledger
      render json: {id: al.id, reference: al.reference, updater: al.updater.to_s, updated_at: I18n.l(al.updated_at)}
    else
      render json: @account_ledger.errors.messages
    end
  end

  # PATCH /account_ledgers/:id/conciliate
  def conciliate
    @conciliate = ConciliateAccount.new(@account_ledger)

    # TODO: Move the logic and control from the model or service
    if @conciliate.conciliate!
      flash[:notice] = 'Se ha verificado la transacción correctamente.'
    else
      flash[:error] = 'No es posible verificar la transacción, quiza fue verificada o anulada'
    end

    redirect_to account_ledger_path(@account_ledger.id)
  end

  # PATCH /account_ledgers/:id/null
  def null
    @null = NullAccountLedger.new(@account_ledger)

    if @null.null!
      flash[:notice] = 'Se ha anulado correctamente la transacción.'
    else
      flash[:error] = 'No fue posible anular la transacción, quiza ya fue verificada o anulada.'
    end

    redirect_to account_ledger_path(@account_ledger.id)
  end


  private

    def set_ledger
      @account_ledger = AccountLedger.find(params[:id])
    end

end
