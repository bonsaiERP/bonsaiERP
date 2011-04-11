# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionsController < ApplicationController
  # GET /transactions
  # GET /transactions.xml
  #def index
  #  @transactions = Transaction.all

  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.xml  { render :xml => @transactions }
  #  end
  #end

  # GET /transactions/1
  # GET /transactions/1.xml
  #def show
  #  @transaction = Transaction.find(params[:id])

  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.xml  { render :xml => @transaction }
  #  end
  #end

  # GET /transactions/new
  # GET /transactions/new.xml
  #def new
  #  @transaction = Transaction.new

  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.xml  { render :xml => @transaction }
  #  end
  #end

  # GET /transactions/1/edit
  #def edit
  #  @transaction = Transaction.find(params[:id])
  #end

  # POST /transactions
  # POST /transactions.xml
  #def create
  #  @transaction = Transaction.new(params[:transaction])

  #  respond_to do |format|
  #    if @transaction.save
  #      format.html { redirect_to(@transaction, :notice => 'Transaction was successfully created.') }
  #      format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
  #    else
  #      format.html { render :action => "new" }
  #      format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  #def update
  #  @transaction = Transaction.org.find(params[:id])

  #  respond_to do |format|
  #    if @transaction.update_attributes(params[:transaction])
  #      format.html { redirect_to(@transaction, :notice => 'Transaction was successfully updated.') }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  #def destroy
  #  @transaction = Transaction.org.find(params[:id])
  #  @transaction.destroy

  #  respond_to do |format|
  #    format.html { redirect_to(transactions_url) }
  #    format.xml  { head :ok }
  #  end
  #end

  # GET /transactions/:id/pdf
  def pdf
    t = Transaction.org.find(params[:id])
    inv = InvoicePdf.new(t)
 
    name = "#{Rails.root}/tmp/pdfs/#{ t.type }_#{t.id}.pdf"
    inv.generate_pdf(name)

    send_file name, :file_name => "#{t.pdf_name}.pdf"
    File.delete(name)
  end

  # GET /transactions/new_email/:id
  def new_email
    @transaction = Transaction.org.find(params[:id])
  end

  # POST /transactions/email/:id
  # Sends the invoice email
  def email
    @transaction = Transaction.org.find(params[:id])
    InvoiceMailer.send_invoice(@transaction, params).deliver
  end
end
