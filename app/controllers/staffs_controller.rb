# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StaffsController < ApplicationController
  before_filter :find_staff, :only => [:show, :edit, :update, :destroy]

  include Controllers::Contact

  #respond_to :html, :xml, :json
  # GET /staffs
  # GET /staffs.xml
  def index
    params[:option] ||= 'all' 
    if params[:search]
      @staffs = Staff.search(params[:search]).order("matchcode ASC").page(@page)
    else
      case
      when params[:option] === 'pendent'
        @staffs = Staff.pendent.page(@page)
      when params[:option] === 'debt'
        @staffs = Staff.debt.page(@page)
      else
        @staffs = Staff.order("matchcode ASC").page(@page)
      end
    end
  end

  # GET /staffs/1
  # GET /staffs/1.xml
  def show
    params[:tab] = "transactions"
    params[:option] = "all" unless ["all", "con", "pendent", "nulled"].include?(params[:option])
    @partial = "contacts/account_ledgers"
    @ledgers = AccountLedger.staff(@staff.id)
    @ledgers = @ledgers.send(params[:option]) unless params[:option] === "all"

    @locals = {
      :ledgers => @ledgers.page(@page),
      :pendent => AccountLedger.staff(@staff.id).send(:pendent).size,
      :contact => @staff
    }
  end

  # GET /staffs/new
  # GET /staffs/new.xml
  def new
    @staff = Staff.new
  end

  # GET /staffs/1/edit
  def edit
  end

  # POST /staffs
  # POST /staffs.xml
  def create
    @staff = Staff.new(params[:staff])

    if @staff.save
      if request.xhr?
        render :json => @staff#.to_json( :methods => [:account_id, :account_name] )
      else
        redirect_to @staff
      end
    else
      render :action => 'new'
    end
  end

  # PUT /staffs/1
  # PUT /staffs/1.xml
  def update
    if @staff.update_attributes(params[:staff])
      redirect_to @staff
    else
      render :action => 'edit'
    end
  end

  # DELETE /staffs/1
  # DELETE /staffs/1.xml
  #def destroy
  #  @staff.destroy
  #  redirect_ajax(@staff)
  #end

  protected
  def find_staff
    @staff = Staff.find(params[:id])
  end
end

