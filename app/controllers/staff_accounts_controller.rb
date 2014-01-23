class StaffAccountsController < ApplicationController
  before_filter :set_staff_account, only: [:show, :edit, :update, :destroy]

  include Controllers::Money

  # GET /staff_accounts
  def index
    @staff_accounts = present StaffAccount.order('name asc'), MoneyAccountPresenter
  end

  # GET /staff_accounts/:id
  def show;  end

  # GET /staff_accounts/new
  def new
    @staff_account = StaffAccount.new
  end

  # GET /staff_accounts/1/edit

  # POST /staff_accounts
  def create
    @staff_account = StaffAccount.new(staff_account_params)

    if @staff_account.save
      redirect_to(staff_account_path(@staff_account), notice: 'La cuenta personal fue creada.')
    else
      render :new
    end
  end

  # PUT /staff_accounts/1
  def update
      if @staff_account.update_attributes(staff_account_params)
        redirect_to(@staff_account, notice: 'La cuenta personal fue actualizada.')
      else
        render :edit
      end
  end

  # DELETE /staff_accounts/1
  def destroy
    @staff_account.destroy

    redirect_to(staff_accounts_url)
  end

  private

    def set_staff_account
      @staff_account = present StaffAccount.find(params[:id]), MoneyAccountPresenter
    end

    def staff_account_params
      params.require(:staff_account).permit(:name, :currency, :amount, :email,
                                            :address, :active, :phone, :mobile)
    end

end
