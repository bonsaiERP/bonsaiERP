# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'csv'

class Movements::Export
  attr_reader :col_sep, :rate, :date_range

  def initialize(dr)
    @date_range = dr
  end

  delegate :currency, to: OrganisationSession

  def export(rel, col_sep = ",")
    CSV.generate(col_sep: col_sep) do |csv|
      csv << csv_header
      rel.joined.active.date_range(date_range.range).order('date asc, id asc').each do |trans|
        self.rate = trans.exchange_rate

        csv << [trans.name, state(trans.state), date(trans.date), trans.cont, rep(trans.description),
                val_cur(trans.tot), val_cur(trans.balance), trans.exchange_rate, trans.currency]
      end
    end
  end

private
  def rate=(v)
    @rate = v
  end

  def val_cur(val)
    val.to_d * rate
  end

  def date(val)
    I18n.l(val, format: I18n.t('date.formats.excel'))
  end

  def csv_header
    %W(#{trans_name} Estado Fecha Contacto Descripción Total\ #{currency} Saldo\ #{currency} Tipo\ de\ Cambio Moneda)
  end

  def trans_name
  end

  def state(st)
    case st
    when "draft"    then 'borrador'
    when "approved" then 'aprobado'
    when "paid"     then 'pagado'
    when "nulled"   then 'anulado'
    end
  end

  def rep(val)
    val.to_s.gsub(/(\n|\t|\r)/, " ")
  end
end
