class CurrencyRatesController < ApplicationController
  # GET /currency_rates
  # GET /currency_rates.xml
  def index
    @currency_rates = CurrencyRate.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @currency_rates }
    end
  end

  # GET /currency_rates/1
  # GET /currency_rates/1.xml
  def show
    @currency_rate = CurrencyRate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @currency_rate }
    end
  end

  # GET /currency_rates/new
  # GET /currency_rates/new.xml
  def new
    if CurrencyRate.current?(params[:organisation_id])
      # TODO: Must log and set error
    else
      @organisation = Organisation.find(params[:organisation_id])
      @currency_rates = CurrencyRate.build_currencies(@organisation)
    end
  end

  # GET /currency_rates/1/edit
  def edit
    @currency_rate = CurrencyRate.find(params[:id])
  end

  # POST /currency_rates
  # POST /currency_rates.xml
  def create
    unless current_user.check_organisation?(params[:currency_rate][:organisation_id])
      # TODO: Must log and set that the current user is hacking
    else
      values = params[:currency_rates].map{ |v| v.last.merge(:organisation_id => params[:currency_rate][:organisation_id] ) }
      @currency_rates = CurrencyRate.create(values)
      unless @currency_rates.map(&:id).include?(nil)
        redirect_ajax @currency_rates.first, :url => currency_rates_path
      else
        @organisation = Organisation.find(params[:currency_rate][:organisation_id])
        render :action => 'new'
      end
    end
  end

  # PUT /currency_rates/1
  # PUT /currency_rates/1.xml
  def update
    @currency_rate = CurrencyRate.find(params[:id])

    respond_to do |format|
      if @currency_rate.update_attributes(params[:currency_rate])
        format.html { redirect_to(@currency_rate, :notice => 'Currency rate was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @currency_rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /currency_rates/1
  # DELETE /currency_rates/1.xml
  def destroy
    @currency_rate = CurrencyRate.find(params[:id])
    @currency_rate.destroy

    respond_to do |format|
      format.html { redirect_to(currency_rates_url) }
      format.xml  { head :ok }
    end
  end

  # JSON method to check if an organisation has set the rates
  def check
    render :json => { :success => CurrencyRate.current?(params[:id]) }
  end
end
