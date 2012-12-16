# encoding: utf-8
class UserChange < ActiveRecord::Base
  # Relationships
  belongs_to :user
  belongs_to :user_changeable, polymorphic: true

  # Validations
  validates_presence_of :user, :user_id, :name
end
