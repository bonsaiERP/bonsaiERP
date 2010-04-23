module UUIDHelper
  def self.included(base)
    base.instance_eval do
      include InstanceMethods
      attr_readonly :id
      before_create :set_uuid
    end
    #base.send(:include, ClassMethods)
    #base.send(:before_create, :set_uuid)
  end

  module InstanceMethods
private
    def set_uuid
      self.id = UUID.new.generate# UUIDTools::UUID.random_create.to_s
    end
  end
end
