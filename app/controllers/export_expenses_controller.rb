# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExportExpensesController < ApplicationController
  # GET /export_incomes
  def index
  end

  # POST /export_incomes
  def create
    #begin
    exp = ExportExpenses.new(export_params)
    if exp.valid?
      respond_to do |format|
        format.xls { send_data StringEncoder.encode("UTF-8", "ISO-8859-1", exp.export(col_sep: "\t") ), filename: 'egresos.xls' }
      end
    else
      flash[:error] ='Existen errores en los datos.'
      redirect_to export_expenses_path
    end
    #rescue
    #end
  end

private
  def export_params
    params.slice(:date_start, :date_end)
  end
end
