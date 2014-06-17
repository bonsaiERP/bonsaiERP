class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Bonsaierp::Application.routes.draw do
  draw :api
  draw :app

  root to: 'sessions#new'
end
