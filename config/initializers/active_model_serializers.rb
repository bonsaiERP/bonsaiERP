#ActiveSupport.on_load(:action_controller) do
#  wrap_parameters format: [:json]
#end
#
## Disable root element in JSON by default.
#ActiveSupport.on_load(:active_record) do
#  self.include_root_in_json = false
#end
#
#BSA ActiveModel::Serializer.root false
#BSA ActiveModel::ArraySerializer.root = false
# Without root, the default
ActiveModel::Serializer.config.adapter = :flatten_json

# With root
ActiveModel::Serializer.config.adapter = :json

# Following JSON API conventions
ActiveModel::Serializer.config.adapter = :json_api

ActiveSupport.on_load(:active_model_array_serializer) do
  self.root = false
end

ActiveModel::Serializer.class_eval do
  def to_s
    object.to_s
  end
end
