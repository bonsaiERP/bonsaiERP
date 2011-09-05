# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AutocompleteApp < BaseApp
  include ActionController::Rendering
  include ActionController::Renderers::All

  #def client
  #  self.response_body =  Client.all.map {|c| {:label => c.to_s, :id => c.id} }.to_json
  #end

  # Define autocomplee methods for contact
  #%w(client supplier staff).each do |method|
  #  class_eval <<-CODE, __FILE__, __LINE__ + 1
  #    def #{method}
  #      self.reponse_body = contact_autocomplete(#{method}.titularize, params)
  #    end
  #  CODE
  #end
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

  def client_account
    render :json => contact_account_autocomplete('Client', params)
  end

  def supplier_account
    render :json => contact_account_autocomplete('Supplier', params)
  end

  def staff_account
    render :json => contact_account_autocomplete('Staff', params)
  end

private
  # Search for contact autocomlete
  def contact_autocomplete(type, options)
    set_organisation_session
    Contact.org.where("type = :type AND matchcode LIKE :term", :type => type, :term => "%#{options[:term]}%").limit(20).map {|c| {:id => c.id, :label => c.to_s}}
  end

  def item_autocomplete(options)
    set_organisation_session
    Item.simple_search(options[:term]).to_json
  end

  def contact_account_autocomplete(type, options)
    set_organisation_session
    Account.org.where("original_type = :type AND name LIKE :term", :type => type, :term => "%#{options[:term]}%").limit(20).map {|c| {:id => c.id, :label => c.to_s}}
  end
end
