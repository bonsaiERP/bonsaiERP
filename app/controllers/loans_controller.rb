class LoansController < ApplicationController

  # GET /loans
  def index
    @loans = present Loans::Query.new.all_loans.page(@page)
  end

  # GET /loans_receive/new
  def new_receive
    @loan = Loans::ReceiveForm.new(date: Date.today, due_date: Date.today)
  end

  # POST /loans_receive
  def receive
    @loan = Loans::ReceiveForm.new(receive_params)

    if @loan.create
       redirect_to loan_path(@loan.id), notice: 'Se ha recibido un prestamo.'
    else
      render :new_receive
    end
  end

  # /loans/new_give
  def new_give
    @loan = Loans::GiveForm.new(date: Date.today, due_date: Date.today)
  end

  # /loans/give
  def give
    @loan = Loans::GiveForm.new(give_params)

    if @loan.create
      redirect_to loan_path(@loan.id), notice: 'Se ha dado un prestamo.'
    else
      render :new_give
    end
  end

  # GET /loans/:id
  def show
    @loan = present Loan.find(params[:id])
  end

  private

    def loan_params
      [:contact_id, :date, :due_date, :account_to_id,
       :total, :reference, :exchange_rate]
    end

    def give_params
      params.require(:loans_give_form).permit(*loan_params)
    end

    def receive_params
      params.require(:loans_receive_form).permit(*loan_params)
    end
end
