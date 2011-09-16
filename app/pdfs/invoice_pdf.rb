# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that creates the PDF file to be suplend with the document and inquiry in the mail
class InvoicePdf < BasePdf

  def initialize(transaction)
    super()
    @transaction = transaction
    #@document = document
    #@inquiry_detail = inquiry_detail
    w, h, @w, @h = page.dimensions
  end

  def generate_pdf(file_path)

    create_contact_box
    create_invoice_title
    
    create_exchange_rate
    create_transaction_details
    create_totals

    render_file(file_path)
  end

  # Creates the information for the contact
  def create_contact_box
    bounding_box([10, @h - 250], :width => 270, :height => 120) do
      text "#{@transaction.contact.pdf_name}"
      text "#{@transaction.contact.organisation_name}", :style => :bold unless @transaction.contact.organisation_name.blank?
      text "#{@transaction.contact.address}"
    end
  end

  # Creates the number for the invoice
  def create_invoice_title
    bounding_box([300, @h - 250], :width => 270, :height => 120) do
      text "#{@transaction.pdf_title}", :style => :bold, :size => 11
      text I18n.l(@transaction.created_at.to_date)
    end
  end

  def create_exchange_rate
    unless OrganisationSession.currency_id == @transaction.currency_id
      excrate = "1 #{@transaction.currency_name} = #{number_to_currency @transaction.exchange_rate, :precision => 4} "
      excrate << "#{Currency.find(OrganisationSession.currency_id).plural}"
      text "Tipo de cambio: <b>#{excrate}</b>", :inline_format => true
    end
  end

  # Creates the table with the data of details
  def create_transaction_details
    table([["<b>Item</b>", "<b>Precio\nUnitario</b>", '<b>Cantidad</b>', "<b>Total\nFila</b>"]] + create_table_data, :header => true, 
          :column_widths => [210, 80, 80, 80], :width => 450, :cell_style => {:border_width => 0.3, :inline_format => true} ) do
      style(row(0), :background_color => 'efefef')
      style(column(1)) { |c| c.align= :right }
      style(column(2)) { |c| c.align= :right }
      style(column(3)) { |c| c.align= :right }
    end
  end

  # Creates the data for table
  def create_table_data
    arr = []
    @transaction.transaction_details.includes(:item).each do |td|
      arr << [ td.item.to_s, number_to_currency(td.price), number_to_currency(td.quantity), number_to_currency(td.total) ]
    end
    arr
  end

  # Creates te totals for the invoice
  def create_totals
    org = OrganisationSession
    arr = [["Subtotal:",   "#{org.currency_symbol} #{number_to_currency(@transaction.total)}"]]
    arr << ["Descuentos: #{number_to_currency(@transaction.discount)}",   "#{org.currency_symbol} #{number_to_currency(@transaction.total_taxes)}"] if @transaction.discount.present? and @transaction.discount > 0
    arr << ["Impuestos:",   "#{org.currency_symbol} #{number_to_currency(@transaction.total_taxes)}"] if @transaction.tax_percent.present? and @transaction.tax_percent > 0

    arr << ["<b>Total #{org.currency_name.pluralize}</b>", "<b>#{org.currency_symbol} #{number_to_currency(@transaction.total)}</b>"]
    arr << ["<b>Total #{@transaction.currency_name.pluralize}</b>", "<b>#{@transaction.currency_symbol} #{number_to_currency(@transaction.total_currency)}</b>"] unless org.currency_id == @transaction.currency_id

    table(arr, :width => 450, :column_widths => [370, 80], :cell_style => {:border_width => 0, :align => :right, :inline_format => true } )
  end


end
