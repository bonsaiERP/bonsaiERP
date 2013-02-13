# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InvoiceMailer < ActionMailer::Base
  default from: "#{APP_NAME} <noresponder@bonsaierp.com>"

  layout "email"

  # Sends the invoice docment to the contact
  def send_invoice(transaction, options)
    @transaction = transaction
    @message = options[:body]

    attach_invoice_pdf

    mail(:to => @transaction.contact.email, :subject => options[:title] )
  end

  def attach_invoice_pdf
    inv = InvoicePdf.new( @transaction )
    name = "#{Rails.root}/tmp/pdfs/#{ Time.now.to_f }_#{@transaction.id}.pdf"
    inv.generate_pdf(name)
    if @transaction.draft?
      attachments["proforma_de_venta.pdf"] = File.read(name)
    else
      attachments["nota_de_venta.pdf"] = File.read(name)
    end
    File.delete(name)
  end

end
