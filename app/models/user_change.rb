class UserChange < ActiveRecord::Base
  attr_accessible :name, :user_changeable_id, :user_changeable_type
end
