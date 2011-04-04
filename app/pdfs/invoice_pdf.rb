# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that creates the PDF file to be suplend with the document and inquiry in the mail
class InvoicePdf < BasePdf

  def initialize()
    super()
    #@document = document
    #@inquiry_detail = inquiry_detail
    #w, h, @w, @h = page.dimensions
  end

  def generate_pdf(file_path)
    
    #if @document.ctype == "Lieferschein" 
    #  create_delivery_header 
    #else
    #  create_company_header
    #end
    #create_admin_header
    #create_document_title
    #text @document.headertext
    #create_machine_details
    #text "\n"
    #create_totals if @document.ctype !="Lieferschein"
    #
    #text "\n\n#{@document.footertext}\n\n"
  # # create_footer_data
    #text "\n"
  #  bank_data

    #text "#{"Repeats many times" * 30}"#####
    #self
    render_file(file_path)
  end

  def create_footer_data
    arr = [
      [ "Ihre USt-IdNr.: #{@inquiry_detail.company.eu_ust_indent_number}\nUnsere USt-IdNr.:    DE 329 320 439\n#{@document.erloscode}"]
    ]
    table(arr, :width => 450, :cell_style => {:border_width => 0})
  end

  def create_totals
    arr = [["", "Summe:",   "#{number_to_currency(@document.total)}"]]
    if @inquiry_detail.company.postal_country.name == "Deutschland"  
      arr << ["", "MwSt 19%:",   "#{number_to_currency(@document.tax_total)}"]
      arr << ["", "<b>Summe inkl. MwSt:</b>", "<b>#{number_to_currency(@document.total_with_tax)}</b>"]
    end
    table(arr, :width => 450, :column_widths => [150, 200, 100], :cell_style => {:border_width => 0, :align => :right, :inline_format => true } )
  end

  # Sets the company with the data
  def create_company_header
    bounding_box([10, @h - 260], :width => 270, :height => 150) do
      company = @inquiry_detail.company
      text "#{@inquiry_detail.company.name1}"
      text "#{@inquiry_detail.contact}" if @inquiry_detail.contact_id
      text "#{company.postal_street}"
      text "#{company.postal_postal} #{@inquiry_detail.company.postal_city}"
      text "#{@inquiry_detail.company.try(:postal_country)}"
    end
  end
  # Sets the deliveryadress with the data
  def create_delivery_header
    bounding_box([10, @h - 260], :width => 270, :height => 150) do
      company = @inquiry_detail.company
      text "#{@inquiry_detail.company.name1}"
      text "#{@inquiry_detail.contact}" if @inquiry_detail.contact_id
      text "#{company.delivery_street}"
      text "#{company.delivery_postal} #{@inquiry_detail.company.delivery_city}"
      text "#{@inquiry_detail.company.try(:delivery_country)}"
      text "                   "
      text "Rechnungsanschrift:"
      company = @inquiry_detail.company
      text "  #{@inquiry_detail.company.name1}"
      text "  #{@inquiry_detail.contact}" if @inquiry_detail.contact_id
      text "  #{company.postal_street}"
      text "  #{company.postal_postal} #{@inquiry_detail.company.postal_city}"
      text "  #{@inquiry_detail.company.try(:postal_country)}"
    end
  end

  def create_admin_header
    inq = @inquiry_detail.inquiry
    bounding_box([@w - 350, @h - 220], :width => 270, :height => 200) do
      text "Ihr Ansprechpartner: "
      text "#{ inq.admin.to_s }(Tel. #{inq.admin.phone})"
      text "E-Mail: #{inq.admin.email}"
      text "\n"
      text "Ihre Kundennummer: #{@inquiry_detail.company.datev_konto} #{@inquiry_detail.company.datev_konto_kreditor}"
      text "Ihre USt-IdNr.: #{@inquiry_detail.company.eu_ust_indent_number}"
      text "Unsere USt-IdNr.:    DE 329 320 439\n#{@document.erloscode}"
      text "\n"
      text "Bankverbindung: "
      text "Kto. 461 126 006"
      text "Naspa Eltville  (BLZ 510 500 15)"
      text "IBAN: DE40 5105 0015 0461 1260 06"
      text "BIC:    NASSDE55XXX"
    end
  end

  def create_document_title
    text "#{@document.ctype} #{@document.document_number}, #{I18n.l @document.created_at, :format => I18n.t("date.formats.default")}"
  end

  def create_machine_details
    table([['<b>Pos.</b>', '<b>Machine</b>', '<b>EUR</b>']] + create_table_data, :header => true, 
          :column_widths => [30, 340, 80], :width => 450, :cell_style => {:border_width => 0.3, :inline_format => true} ) do
      style(row(0), :background_color => 'efefef')
      style(column(2)) { |c| c.align= :right }
    end
  end

  def bank_data
    text "Bankverbindung: Naspa Eltville, Kto. 461 126 006 (BLZ 510 500 15)
    #{ " " * 10}IBAN:     DE40 5105 0015 0461 1260 06
    #{" " * 11} BIC:    NASSDE55XXX"
  end

  # Creates the data for table
  def create_table_data
    arr = []
    @document.document_machines.each_with_index do |dm, i|
      text = "<b>#{dm.title}</b>\n#{dm.description.gsub(DocumentMachine::BR, '\n')}"
      arr << ["#{i+1}", text, @document.ctype == "Lieferschein" ? "" : number_to_currency(dm.price)]
    end
    arr
  end

  def ren
    generate_pdf(File.join(Rails.public_path, 'h.pdf'))
  end
end
