# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlansController < ApplicationController
  
  before_filter :set_pay_plan, :only => [:show, :edit, :update, :destroy]
  # GET /pay_plans
  # GET /pay_plans.xml
  def index
    @pay_plans = PayPlan.org.paginate(:page => @page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pay_plans }
    end
  end

  # GET /pay_plans/1
  # GET /pay_plans/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pay_plan }
    end
  end

  # GET /pay_plans/new
  # GET /pay_plans/new.xml
  def new
    begin
      transaction = Transaction.find_by_type_and_id( params[:type], params[:id] )
      @pay_plan = transaction.new_pay_plan
    rescue
      redirect_to request.referer
    end
  end

  # GET /pay_plans/1/edit
  def edit
  end

  # POST /pay_plans
  # POST /pay_plans.xml
  def create
    begin
      @transaction = Transaction.org.find(params[:pay_plan][:transaction_id])
      @pay_plan = @transaction.new_pay_plan(params[:pay_plan])

      if @pay_plan.valid? and @transaction.create_pay_plan(params[:pay_plan])
        params[:ajax_modal] = true
        render :partial => 'pay_plans', :locals => { :transaction => @transaction }
      else
        render :action => "new"
      end
    rescue
      render :text => "Existio un error por favor cierre la ventana."
    end
  end

  # PUT /pay_plans/1
  # PUT /pay_plans/1.xml
  def update
    begin
      @transaction = Transaction.org.find(params[:pay_plan][:transaction_id])
      @pay_plan = @transaction.new_pay_plan(params[:pay_plan])
      options = params[:pay_plan].merge(:id => params[:id])

      if @pay_plan.valid? and @transaction.update_pay_plan(options) 
        params[:ajax_modal] = true
        render :partial => 'pay_plans', :locals => { :transaction => @transaction }
      else
        @pay_plan.id = params[:id].to_i
        render :action => "edit"
      end
    rescue
      render :text => "Existio un error por favor cierre la ventana."
    end
  end

  # DELETE /pay_plans/1
  # DELETE /pay_plans/1.xml
  def destroy
    begin
      @pay_plan = PayPlan.find(params[:id])
      @transaction = Transaction.org.find(@pay_plan.transaction_id)

      if @transaction.destroy_pay_plan(@pay_plan.id)
        render :partial => 'pay_plans', :locals => { :transaction => @transaction }
      else
        render :text => {:success => false}.to_json
      end
    rescue
      render :text => "Existio un error por favor cierre la ventana."
    end
  end

  def show
    @transaction = Transaction.org.find(params[:id])
    params[:ajax_modal] = true
    render :partial => 'pay_plans', :locals => { :transaction => @transaction }
  end

private
  def set_pay_plan
    @pay_plan = PayPlan.org.find(params[:id])
  end
end
