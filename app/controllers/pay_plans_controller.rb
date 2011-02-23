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
    @pay_plan = PayPlan.new(params[:pay_plan])
    if @pay_plan.save
      redirect_ajax(@pay_plan, :notice => 'Se ha creado una proforma de venta.')
    else
      render :action => "new"
    end
  end

  # PUT /pay_plans/1
  # PUT /pay_plans/1.xml
  def update
    if @pay_plan.update_attributes(params[:pay_plan])
      redirect_ajax(@pay_plan, :notice => 'PayPlans was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /pay_plans/1
  # DELETE /pay_plans/1.xml
  def destroy
    @pay_plan.destroy

    redirect_ajax @pay_plan
  end

private
  def set_pay_plan
    @pay_plan = PayPlan.org.find(params[:id])
  end
end
