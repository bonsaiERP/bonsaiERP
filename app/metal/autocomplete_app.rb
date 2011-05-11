# encoding: utf-8
class AutocompleteApp < ActionController::Metal
  #include ActionController::Rendering

  def client
    self.response_body =  Client.all.map {|c| {:label => c.to_s, :id => c.id} }.to_json
  end

private
  def autocomplete(options)

  end
  
end
