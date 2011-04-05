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

  # Creates te number for the invoice
  def create_invoice_title
    bounding_box([300, @h - 250], :width => 270, :height => 120) do
      text "#{@transaction.pdf_title}", :style => :bold, :size => 11
      text I18n.l(@transaction.date)
    end
  end

  def create_exchange_rate
    unless OrganisationSession.currency_id == @transaction.currency_id
      excrate = "1 #{@transaction.currency_name} = #{number_to_currency @transaction.currency_exchange_rate, :precision => 4} "
      excrate << "#{Currency.find(OrganisationSession.currency_id).plural}"
      text "Tipo de cambio: <b>#{excrate}</b>", :inline_format => true
    end
  end

  #def create_footer_data
  #  arr = [
  #    [ "Ihre USt-IdNr.: #{@inquiry_detail.company.eu_ust_indent_number}\nUnsere USt-IdNr.:    DE 329 320 439\n#{@document.erloscode}"]
  #  ]
  #  table(arr, :width => 450, :cell_style => {:border_width => 0})
  #end

  # Creates the table with the data of details
  def create_transaction_details
    table([["<b>Item</b>", "<b>Precio\nUnitario</b>", '<b>Cantidad</b>', "<b>Total\nFila</b>"]] + create_table_data, :header => true, 
          :column_widths => [300, 80, 80, 80], :width => 450, :cell_style => {:border_width => 0.3, :inline_format => true} ) do
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
    arr = [["", "Summe:",   "#{number_to_currency(@document.total)}"]]
    if @inquiry_detail.company.postal_country.name == "Deutschland"  
      arr << ["", "MwSt 19%:",   "#{number_to_currency(@document.tax_total)}"]
      arr << ["", "<b>Summe inkl. MwSt:</b>", "<b>#{number_to_currency(@document.total_with_tax)}</b>"]
    end
    table(arr, :width => 450, :column_widths => [150, 200, 100], :cell_style => {:border_width => 0, :align => :right, :inline_format => true } )
  end

  def ren
    generate_pdf(File.join(Rails.public_path, 'h.pdf'))
  end
end
