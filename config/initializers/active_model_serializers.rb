#ActiveSupport.on_load(:action_controller) do
#  wrap_parameters format: [:json]
#end
#
## Disable root element in JSON by default.
#ActiveSupport.on_load(:active_record) do
#  self.include_root_in_json = false
#end
#
ActiveModel::Serializer.root false
ActiveModel::ArraySerializer.root = false

ActiveSupport.on_load(:active_model_array_serializer) do
  self.root = false
end

ActiveModel::Serializer.class_eval do
  def to_s
    object.to_s
  end
end
