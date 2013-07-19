# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that creates the PDF file
class InvoicePdf < BasePdf

  def initialize(movement)
    super()
    @movement = movement
    #@document = document
    #@inquiry_detail = inquiry_detail
    w, h, @w, @h = page.dimensions
  end

  def generate_pdf(file_path)
    create_contact_box
    create_invoice_title

    create_movement_details
    create_totals

    render_file(file_path)
  end

private
  # Creates the information for the contact
  def create_contact_box
    bounding_box([10, @h - 250], :width => 270, :height => 120) do
      text "#{contact_name @movement.contact}", style: :bold
      text "#{@movement.contact.organisation_name}", style: :bold unless @movement.contact.organisation_name.blank?
      text "#{@movement.contact.address}"
    end
  end

  # Creates the number for the invoice
  def create_invoice_title
    bounding_box([300, @h - 250], :width => 270, :height => 120) do
      text "#{title}", :style => :bold, :size => 11
      text I18n.l(@movement.created_at.to_date)
    end
  end

  def title
    case
    when @movement.is_a?(Income)
      "Ingreso #{@movement}"
    when @movement.is_a?(Expense)
      "Egreso #{@movement}"
    end
  end

  # Creates the table with the data of details
  def create_movement_details
    table([["<b>Item</b>", "<b>Precio\nUnitario #{@movement.currency}</b>", 
            '<b>Cantidad</b>', "<b>Total\nFila #{@movement.currency}</b>"]] + create_table_data, :header => true, 
          :column_widths => [280, 70, 70, 80], :width => 500, :cell_style => {:border_width => 0.3, :inline_format => true} ) do
      style(row(0), :background_color => 'efefef')
      style(column(1)) { |c| c.align= :right }
      style(column(2)) { |c| c.align= :right }
      style(column(3)) { |c| c.align= :right }
    end
  end

  # Creates the data for table
  def create_table_data
    arr = []
    @movement.details.includes(:item).each do |td|
      arr << [ td.item.to_s, number_to_currency(td.price), number_to_currency(td.quantity), number_to_currency(td.total) ]
    end
    arr
  end

  # Creates te totals for the invoice
  def create_totals
    org = OrganisationSession
    arr = [["Subtotal:",   "#{number_to_currency(@movement.total)}"]]
    #arr << ["Descuentos (#{number_to_currency(@movement.discount)} %):", "- #{number_to_currency(@movement.total_discount)}"] if @movement.discount.present? and @movement.discount > 0

    arr << ["<b>Total</b>", "<b>#{@movement.currency} #{number_to_currency(@movement.total)}</b>"]

    table(arr, :width => 500, :column_widths => [420, 80], :cell_style => {:border_width => 0, :align => :right, :inline_format => true } )
  end

private
  def contact_name(cont)
    if cont.first_name && cont.last_name
      "#{cont.first_name} #{cont.last_name}"
    else
      cont.to_s
    end
  end

end
