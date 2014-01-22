class StaffAccountsController < ApplicationController
  before_filter :set_staff_acccount, only: [:show, :edit, :update, :destroy]

  include Controllers::Money

  # GET /staff_acccounts
  def index
    @staff_acccountes = present StaffAcccount.order('name asc'), MoneyAccountPresenter
  end

  # GET /staff_acccounts/1

  # GET /staff_acccounts/new
  def new
    @staff_acccount = StaffAcccount.new
  end

  # GET /staff_acccounts/1/edit

  # POST /staff_acccounts
  def create
    @staff_acccount = StaffAcccount.new(staff_acccount_params)

    if @staff_acccount.save
      redirect_to(staff_acccount_path(@staff_acccount), notice: 'La cuenta personal fue creada.')
    else
      render :new
    end
  end

  # PUT /staff_acccounts/1
  def update
      if @staff_acccount.update_attributes(staff_acccount_params)
        redirect_to(@staff_acccount, notice: 'La cuenta personal fue actualizada.')
      else
        render :edit
      end
  end

  # DELETE /staff_acccounts/1
  def destroy
    @staff_acccount.destroy

    redirect_to(staff_acccounts_url)
  end

  private

    def set_staff_acccount
      @staff_acccount = present StaffAccount.find(params[:id]), MoneyAccountPresenter
    end

    def staff_acccount_params
      params.require(:staff_acccount).permit(:name, :currency, :amount, :address, :active)
    end
end
