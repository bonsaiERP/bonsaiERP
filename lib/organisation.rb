# Module that helps to add users
module Organisation
  def self.included(base)
    base.send(:include, ClassMethods)
  end

  module ClassMethods
    protected
    # Sets
    def set_user_id
      write_attribute(:user_id, UserSession.current_user.id)
    end
  end

  module InstanceMethods
    def acts_as_organisation
      before_save :set_user_id
    end
  end

end
