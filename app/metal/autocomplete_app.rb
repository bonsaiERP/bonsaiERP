# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AutocompleteApp < BaseApp
  include ActionController::Rendering
  include ActionController::Renderers::All

  def supplier
    render :json => contact_autocomplete('Supplier', params)
  end
  
  def staff
    render :json => contact_autocomplete('Staff', params)
  end

  def client
    render :json => contact_autocomplete('Client', params)
  end

  def item
    render :json => item_autocomplete(params)
  end

  def items_stock
    items = Item.with_stock(params[:store_id], params[:term]).limit(20).map do |v|
      {:id => v.id, :label => v.to_s, :code => v.code, :name => v.name, :quantity => v.quantity}
    end

    render :json => items
  end

  def client_account
    render :json => contact_account_autocomplete('Client', params)
  end

  def supplier_account
    render :json => contact_account_autocomplete('Supplier', params)
  end

  def staff_account
    render :json => contact_account_autocomplete('Staff', params)
  end

  def get_rates
    file = File.join(Rails.root, "public/exchange_rates.json")
    if File.ctime(file) < Time.now - 4.hours
      resp = %x[curl http://openexchangerates.org/latest.json]
      begin
        r = ActionSupport::JSON.decode(resp)
        f = File.new(file, "w+")
        f.write(r)
        f.close
        render :json => r
      rescue
        render :json => File.read(file)
      end
    else
      render :json => File.read(file)
    end
  end

  private
    # Search for contact autocomlete
    def contact_autocomplete(type, options)
      set_search_path
      Contact.where("type = :type AND matchcode ILIKE :term", :type => type, :term => "%#{options[:term]}%").limit(20).map {|c| {:id => c.id, :label => c.to_s}}
    end

    def item_autocomplete(options)
      set_search_path
      if 'Income' == options[:type]
        Item.for_sale.simple_search(options[:term]).to_json
      else
        Item.simple_search(options[:term]).to_json
      end
    end

    def contact_account_autocomplete(type, options)
      set_search_path
      Account.where("original_type = :type AND name LIKE :term", :type => type, :term => "%#{options[:term]}%").limit(20).map {|c| {:id => c.id, :label => c.to_s}}
    end
end
