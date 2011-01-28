# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlansController < ApplicationController

  # GET /pay_plans
  # GET /pay_plans.xml
  def index
    @pay_plans = PayPlan.paginate(:page => @page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pay_plans }
    end
  end

  # GET /pay_plans/1
  # GET /pay_plans/1.xml
  def show
    @pay_plan = PayPlan.find(params[:id])

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
      @pay_plan = PayPlan.new(:transaction_id => transaction.id, :ctype => transaction.type)
    rescue
      redirect_to request.referer
    end
  end

  # GET /pay_plans/1/edit
  def edit
    @pay_plan = PayPlan.find(params[:id])
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
    @pay_plan = PayPlan.find(params[:id])

    if @pay_plan.update_attributes(params[:pay_plan])
      redirect_ajax(@pay_plan, :notice => 'PayPlans was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /pay_plans/1
  # DELETE /pay_plans/1.xml
  def destroy
    @pay_plan = PayPlan.find(params[:id])
    @pay_plan.destroy

    respond_to do |format|
      format.html { redirect_to(pay_plans_url) }
      format.xml  { head :ok }
    end
  end
end
