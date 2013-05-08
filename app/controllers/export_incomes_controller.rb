# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExportIncomesController < ApplicationController
  # GET /export_incomes
  def index
  end

  # POST /export_incomes
  def create
    begin
      respond_to do |format|
        format.xls { send_data ExportIncomes.new(export_params).export(col_sep: "\t"), filename: 'ingresos.xls' }
      end
    rescue
      flash[:error] ='Existen errores en los datos.'
      redirect_to export_incomes_path
    end
  end

private
  def export_params
    params.slice(:date_start, :date_end)
  end
end
