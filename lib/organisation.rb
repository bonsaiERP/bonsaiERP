# Module that helps to add users
module Organisation
  def self.included(base)
  end

  module ClassMethods
    before_save :set_user_id
    
    protected
    # Sets
    def set_user_id
      write_attribute(:user_id, UserSession.user
    end

  end

end
