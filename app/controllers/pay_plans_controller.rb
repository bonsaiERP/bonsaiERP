# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlansController < ApplicationController
  before_filter :check_authorization!
  before_filter :check_pay_plan_authorization, :only => [:new, :create, :edit, :update]
  # GET /pay_plans
  # GET /pay_plans.xml
  def index
    method = params[:option] == "out" ? :out : :in
    @pay_plans = PayPlan.org.unpaid.send(method).includes([:currency, :transaction => :contact]).page(@page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pay_plans }
    end
  end

  # GET /pay_plans/1
  # GET /pay_plans/1.xml
  def show
    params[:ajax_call] = true
    @transaction = Transaction.org.find(params[:id])
  end

  # GET /pay_plans/new
  # GET /pay_plans/new.xml
  def new
    @transaction = Transaction.org.find(params[:id])
    @pay_plan = @transaction.new_pay_plan
  end

  # GET /pay_plans/1/edit
  def edit
    @transaction = Transaction.org.find(params[:transaction_id])
    @pay_plan = @transaction.pay_plans.find(params[:id])
  end

  # POST /pay_plans
  # POST /pay_plans.xml
  def create
    begin
      @transaction = Transaction.org.find(params[:pay_plan][:transaction_id])
    rescue
      render :text => "Existio un error por favor cierre la ventana."
      return false
    end

    @pay_plan = @transaction.new_pay_plan(params[:pay_plan])

    if @transaction.save_pay_plan
      render 'create'
    else
      render :action => "new"
    end
  end

  # PUT /pay_plans/1
  # PUT /pay_plans/1.xml
  def update
    begin
      @transaction = Transaction.org.find(params[:pay_plan][:transaction_id])
    rescue
      render :text => "Existio un error por favor cierre la ventana."
    end

    @pay_plan = @transaction.edit_pay_plan(params[:id], params[:pay_plan])
    options = params[:pay_plan].merge(:id => params[:id])

    if @transaction.save_pay_plan
        render 'create'
    else
      @pay_plan.id = params[:id].to_i
      render :action => "edit"
    end
  end

  # DELETE /pay_plans/1
  # DELETE /pay_plans/1.xml
  def destroy
    begin
      @transaction = Transaction.org.find(params[:id])

      if @transaction.destroy_pay_plans(params[:ids])
        render 'destroy'
      else
        render :json => {:success => false}
      end
    rescue
      render :text => "Existio un error por favor cierre la ventana."
    end
  end

private
  def set_pay_plan
    @pay_plan = PayPlan.org.find(params[:id])
  end

  # Checks if the current user has the rights to edit
  def check_pay_plan_authorization
    unless User.admin_gerency?(session[:user][:rol])
      flash[:warning] = "Usted no tiene acceso a esta acción."

      redirect_to user_path(current_user, :xhr => true)
    end
  end

end
